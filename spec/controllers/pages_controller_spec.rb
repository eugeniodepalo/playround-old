require 'spec_helper'

describe PagesController do
  it "should get index" do
    @controller.sign_in FactoryGirl.create :user
    
    get :index
    
    should redirect_to(rounds_path)
  end
end