module HighriseTags
  include Radiant::Taggable

  desc "Creates an a highrise contact form"
  tag "highrise-contact" do |tag|
    view = response.template
    view.controller.include_javascript 'highrise_contact'
    view.controller.include_stylesheet 'highrise_contact'
    response.template.render :partial => 'shared/highrise_contact.html', :locals =>
    {:contact_type => tag.attr['contact_type'],
     :task_subject=>tag.attr['task_subject'],
     :tags=>(tag.attr['tags']|"").split(','),
     :settings=>HighriseSetting.first,
     :show_additional_info=>tag.attr['show_additional_info'],
     :system_note=>tag.attr['system_note'],
     :return_url=>tag.attr['return_url'],
     :error_url=>tag.attr['error_url'],
     :button_text=>tag.attr['button_text']
    }
  end
end

# These constants are used by the shared/_contact_form partial
# and the highrise_controller
module ContactUsForm
  # These are valid contact_type fields for the _contact_form
  # this causes the contact us form to have a drop down with the type of contact
  # the user will pick the appropriate item and the form will adapt creating
  # notes, tasks and cases as appropriate.

  WEB_SELECT_TYPE = "select_type"
  # this causes the form to create a web support case and a task on the case
  WEB_SUPPORT = "Web Support"
  # this causes the form to create a web lead and a task on the person or address if provided
  WEB_LEAD = "Web Lead"
  # this causes the form to create a retail lead and a task on the person or address if provided
  WEB_RETAIL_LEAD = "Retail Lead"
  # this causes the form to simply put the user into highrise and tag them as Web Opt In
  WEB_OPT_IN = "Web Opt In"
end