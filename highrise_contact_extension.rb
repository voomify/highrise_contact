# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class HighriseContactExtension < Radiant::Extension
  version "1.0.1"
  description "Highrse contact extension allows you to add a contact form that will write to highrise"
  url "http://github.com/voomify/highrise_contact"

  define_routes do |map|
    map.with_options(:controller => 'admin/highrise') do |highrise|
      highrise.link_index           'admin/highrise',             :action => 'index'
      highrise.link_new             'admin/highrise/new',         :action => 'new'
      highrise.link_edit            'admin/highrise/edit/:id',    :action => 'edit'
      highrise.link_remove          'admin/highrise/remove/:id',  :action => 'remove'
    end
  end
  
  # extension_config do |config|
  #   config.gem 'some-awesome-gem
  #   config.after_initialize do
  #     run_something
  #   end
  # end

  # See your config/routes.rb file in this extension to define custom routes
  
   def activate        
    Page.send :include, HighriseTags
    tab 'Settings' do
       add_item "Highrise Contact", "/admin/highrise_settings/edit", :after => "Users"
    end
  end
end

