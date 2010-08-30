ActionController::Routing::Routes.draw do |map|
  map.connect 'admin/highrise_settings/edit', :controller=>'admin/highrise_settings', :action=>'edit'
  map.connect 'admin/highrise_settings/update', :controller=>'admin/highrise_settings', :action=>'update'
  map.connect 'highrise/create', :controller=>'highrise', :action=>'create'

end