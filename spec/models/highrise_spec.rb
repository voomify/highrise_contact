require File.dirname(__FILE__) + '/../spec_helper'

describe Highrise do
  before(:each) do
    @highrise = Highrise.new
  end

  it "should be valid" do
    @highrise.should be_valid
  end
end
