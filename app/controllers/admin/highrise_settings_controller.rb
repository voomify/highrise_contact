class Admin::HighriseSettingsController < ApplicationController  

  def settings
    settings = HighriseSetting.first
    settings = HighriseSetting.new unless settings
    settings
  end

  def set_highrise_connection
    [Highrise::TaskCategory, Highrise::User].each do |klass|
      klass.site=settings.site
    end
  end
  # Remove this line if your controller should only be accessible to users
  # that are logged in:
  #no_login_required
  def update
    if params[:highrise_setting][:id].nil?
      create
      return
    end
    @highrise_setting = HighriseSetting.find(params[:highrise_setting][:id])
    if @highrise_setting.update_attributes(params[:highrise_setting])
      flash[:notice] = 'Highrise Settings were successfully updated.'
    end
  end

  def create
    @highrise_setting = HighriseSetting.new(params[:highrise_setting])
    if @highrise_setting.save
      flash[:notice] = 'Highrise Settings were successfully created.'
    end
  end

  def prepare_task_categories
    begin
      Highrise::TaskCategory.find(:all).collect { |p| [p.name, p.id] }
    rescue Exception=>e
      return []
    end
  end

  def prepare_task_owners
    begin
      Highrise::User.find(:all).collect { |p| [p.name, p.id] }
    rescue Exception=>e
      return  []
    end      
  end

  def edit
    if params[:highrise_setting]
      update
    end
    @highrise_setting = settings    
    set_highrise_connection
    @task_categories = prepare_task_categories
    @task_owners = prepare_task_owners

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
