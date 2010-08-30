class HighriseSetting < ActiveRecord::Base
  validates_presence_of :authentication_token
  validates_presence_of :subdomain

  def validate
    Highrise::User.site = site
    begin
      user = Highrise::User.find(:first)
      return user!=nil
    rescue Exception=>e
      errors.add_to_base "Unable to connect via HTTP to Highrise using authentication token: #{authentication_token} and subdomain: #{subdomain}"
    end
  end

  def site
    return nil unless authentication_token && subdomain
    "https://#{authentication_token}:x@#{subdomain}.highrisehq.com/"    
  end
end
