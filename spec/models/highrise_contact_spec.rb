require File.dirname(__FILE__) + '/../spec_helper'

describe HighriseContact do
  before(:each) do
    @highrise_contact = HighriseContact.new
  end

  it "should be valid" do
    @highrise_contact.should be_valid
  end
end
