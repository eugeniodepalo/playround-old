describe "User" do
  before(:each) do
    @user = Factory.build :user, :email => "matteodepalo@mac.com"
  end
  
  # validity tests
  
  it "should be valid with valid attributes" do
    @user.should be_valid
  end
  
  it "display name should not be allowed to be blank" do
    @user.display_name = ''
    
    @user.should be_invalid
  end
  
  it "real name should not be longer than 30 and less than 3 characters" do
    @user.should ensure_length_of(:real_name).is_at_least(3).is_at_most(30)
  end
  
  it "real name should be allowed to be blank" do
    @user.real_name = nil
    
    @user.should be_valid
    
    @user.real_name = ''
    
    @user.should be_valid
  end
  
  it "display name should be some reasonable default at creation" do
    @user.save!
    
    @user.display_name.should ==  "matteodepalo"
  end
  
  # attributes accessiblity tests
  
  it "should mass-assign display_name" do
    @user.should allow_mass_assignment_of(:display_name)
  end
  
  it "should mass-assign real_name" do
    @user.should allow_mass_assignment_of(:real_name)
  end
  
  it "should mass-assign email" do
    @user.should allow_mass_assignment_of(:email)
  end
  
  it "should mass-assign password" do
    @user.should allow_mass_assignment_of(:password)
  end
  
  it "should mass-assign avatar" do
    @user.should allow_mass_assignment_of(:avatar)
  end
  
  it "should mass-assign town_woeid" do
    @user.should allow_mass_assignment_of(:town_woeid)
  end
  
  # methods tests
  
  it "should return the expected value on subscribed?" do
    @user.save!
    
    round = mock_model('Round')
    round.stub(:full?).and_return(false)
    
    @user.subscribed?(round).should == false
    
    Factory :subscription, :user => @user, :round => round
    
    @user.subscribed?(round).should == true
  end
  
  it "should return the expected vaule on guest?" do
    user = User.new
    
    user.guest?.should == true
    
    @user.save!
    
    @user.guest?.should == false
  end
end