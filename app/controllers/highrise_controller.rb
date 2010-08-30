class HighriseController < SiteController

  #before_filter :check_honeypots, :only => [:create]
  before_filter :set_highrise_connection

  KASE = "Kase"


  #
  # This entry point is called by the product. The form has system information added to it.
  # We create the case and then add the system note.
  #
  def create_in_product
    create{|note_subject, kase_id| add_system_note(note_subject, kase_id)}
  end

  def settings
    HighriseSetting.first
  end

  def set_highrise_connection
    [Highrise::Person, Highrise::Company, Highrise::Kase, Highrise::Note, Highrise::Task].each do |klass|
      klass.site=settings.site
    end
  end

  def create

    #redirect_to :controller=>:site, :action=>:contact_error and return unless honeypot_untouched?

    begin
      email = params[:person][:contact_data][:email_addresses][:email_address][:address]
      company_name = params[:person][:company_name]

      # we find the person if they exist we do NOT overwrite any of their
      # data!
      @person = Highrise::Person.find_by_email email
      unless @person
        @person = Highrise::Person.new(params[:person])
        @person.save
        # If we have a address ... we need the address id
        # we have to fetch it again to get it
        # we do this because we are going to assign task to the address
        @person = Highrise::Person.find @person.id unless company_name.blank?
      end

      # setup defaults
      note_subject = task_subject = @person.id
      contact_type = params[:contact_type]
      tags = params[:tags]

      # if the address name was not provided then tag the person
      if company_name.blank?
        tag_subject(@person, tags)
      # else tag the address and use the address as the task subject
      else
        company = Highrise::Company.find @person.company_id
        tag_subject(company, tags)
        task_subject = company.id
      end

      if contact_type == ContactUsForm::WEB_SUPPORT
        kase = Highrise::Kase.new(params[:kase])
        kase.save
        # Make the note apply to this kase
        params[:note][:collection_type] = KASE
        params[:note][:collection_id] = kase.id
        # make the task apply to this case
        params[:task][:subject_type]=KASE
        task_subject = kase.id
      end

      yield @person.id, kase.id if block_given?

      # we do not add notes or tasks to web_opt_in contacts
      if contact_type != ContactUsForm::WEB_OPT_IN
        note = Highrise::Note.new(add_subject_id(params[:note], @person.id))
        note.save

        task = Highrise::Task.new(add_subject_id(params[:task], task_subject))
        task.save
      end

      # redirect to the page passed into the form partial
      redirect_to params[:return_url]
    rescue => exception
      log_error(exception)
      redirect_to params[:error_url]
    end
  end

private
  def add_system_note(person_id, kase_id)
    params[:system_note][:body] ="<PRE>#{params[:system_note][:body]}</PRE>"
    params[:system_note][:collection_type] = KASE
    params[:system_note][:collection_id] = kase_id
    params[:system_note][:subject_type]= "Party"
    note = Highrise::Note.new(add_subject_id(params[:system_note], person_id))
    note.save
  end

  def add_subject_id(param_hash, id)
      param_hash.merge(:subject_id=>id)
    end

  def tag_subject(subject, tags)
    if tags
        tags.each do |tag|
          subject.tag!(tag)
        end
      end
  end
end
