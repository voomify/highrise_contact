require 'rubygems'

gem 'activeresource'
require 'active_resource'
# we use this for our tag! hack
require 'net/http'

module Highrise
  module Pagination
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_all_across_pages(options = {})
        records = []
        each(options) { |record| records << record }
        records
      end

      def each(options = {})
        options[:params] ||= {}
        options[:params][:n] = 0

        loop do
          if (records = self.find(:all, options)).any?
            records.each { |record| yield record }
            options[:params][:n] += records.size
          else
            break # no people included on that page, thus no more people total
          end
        end
      end
    end
  end
  
  
  class Base < ActiveResource::Base
    self.site = ENV['SITE']

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
  end
  
  # Abstract super-class, don't instantiate directly. Use Kase, Company, Person instead.
  class Subject < Base
    @@curl = `curl` ? true : false
    
    def notes
      Note.find_all_across_pages(:from => "/#{self.class.collection_name}/#{id}/notes.xml")
    end

    def emails
      Email.find_all_across_pages(:from => "/#{self.class.collection_name}/#{id}/emails.xml")
    end

    def upcoming_tasks
      Task.find(:all, :from => "/#{self.class.collection_name}/#{id}/tasks.xml")
    end

    def curl
      @@curl
    end

    def tag!(tag_name)      
      res = nil
      if curl
        res = `curl -s -d 'name=#{tag_name}' #{ENV['SITE']}parties/#{id}/tags`
      else
        res = Net::HTTP.post_form(URI.parse("#{ENV['SITE']}parties/#{id}/tags"),
                                          {'name'=>"#{tag_name}"})
      end
      res
    end
  end
  
  class Kase < Subject
    # find(:all, :from => :open)
    # find(:all, :from => :closed)  
    
    def close!
      self.closed_at = Time.now.utc
      save
    end
  end
  
  class Person < Subject
    
    include Pagination
    
    def self.find_all_across_pages_since(time)
      find_all_across_pages(:params => { :since => time.to_s(:db).gsub(/[^\d]/, '') })
    end

    def self.find_by_email(email)
          Person.find(:first, :from => "/people/search.xml?criteria[email]=#{email}")
    end

    def self.find_by_tag(tag_name)
      people = nil
      tags = Tags.find(:all)
      tags.each do |tag|
        if tag.name == tag_name
          people = Person.find(:all, :from => "/tags/#{tag.id}")
        end
      end
      people
    end

    # method will create a new person by posting the XML
    def self.new_xml(xml)
      results = nil
      #
      #
      #Net::HTTP.post.post("#{ENV['SITE']}/people.xml", xml) do |str|
      #  results = str
      #end
      #results
    end

    def company
      Company.find(company_id) if company_id
    end
    
    def name
      "#{first_name} #{last_name}".strip
    end

    # This is because highrise may return a address as a person using our tag query extension
    # so we make first_name and last_name for a address behave reasonably
    def first_name
      begin
        return super
      rescue
        return nil
      end
    end

    def last_name
      begin
        return super
      rescue
        return nil
      end
    end

    def sortable_name
      "#{last_name}, #{first_name} ".strip
    end

    def email
      addresses = contact_data.email_addresses
      addresses[0] ? addresses[0].address : nil
    end

  end
  
  class Company < Subject
    include Pagination

    def self.find_all_across_pages_since(time)
      find_all_across_pages(:params => { :since => time.to_s(:db).gsub(/[^\d]/, '') })
    end

    def self.find_by_email(email)
          Company.find(:first, :from => "/companies/search.xml?criteria[email]=#{email}")
    end

    def people
      Person.find(:all, :from => "/companies/#{id}/people.xml")
    end

  end
  
  class Note < Base
    include Pagination

    def comments
      Comment.find(:all, :from => "/notes/#{id}/comments.xml")
    end
  end
  
  class Email < Base
    include Pagination

    def comments
      Comment.find(:all, :from => "/emails/#{email_id}/comments.xml")
    end
  end
  
  class Comment < Base
  end

  class Task < Base
    # find(:all, :from => :upcoming)
    # find(:all, :from => :assigned)  
    # find(:all, :from => :completed)  

    def complete!
      load_attributes_from_response(post(:complete))
    end

  end

  class TaskCategory < Base    
  end

  class User < Base
    def join(group)
      Membership.create(:user_id => id, :group_id => group.id)
    end
  end

  class Group < Base
    # Auto-loads the users collection
  end
  
  class Membership < Base
  end

  class ContactData < Base
  end

  class Phone < Base
  end

  class Deal < Base
  end

  class Tags < Base            
  end

end