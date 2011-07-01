require 'spec_helper'

describe Round do
  before(:each) do
    stub_geocoder
    
    @round = Factory.build :round
  end
  
  # validity tests
  
  it "should be valid with valid attributes" do
    assert @round.valid?
  end
  
   it "should not be valid without a deadline" do
    @round.should validate_presence_of(:deadline)
  end
  
  it "should not be valid without a date" do
    @round.should validate_presence_of(:date)
  end
  
  it "should not be valid without maximum people" do
    @round.should validate_presence_of(:max_people)
  end
  
  it "should not be valid without minimum people" do
    @round.should validate_presence_of(:min_people)
  end
  
  it "should not be valid without an arena" do
    @round.should validate_presence_of(:arena_id)
  end
  
  it "should not be valid without a game" do
    @round.should validate_presence_of(:game_id)
  end
  
  it "should be invalid without a user" do
    @round.should validate_presence_of(:user_id)
  end
  
  it "minimum people should not be nil at creation" do
    round = Round.new
    
    round.min_people.should_not be_nil
  end
  
  it "maximum people should not be nil at creation" do
    round = Round.new
    
    round.max_people.should_not be_nil
  end
  
  it "confirmed should not be nil at creation" do
    round = Round.new
    
    round.confirmed.should_not be_nil
  end
  
  it "date should not be nil at creation" do
    round = Round.new
    
    round.date.should_not be_nil
  end
  
  it "deadline should not be nil at creation" do
    round = Round.new
    
    round.deadline.should_not be_nil
  end
  
  it "confirmed should be false at creation" do
    round = Round.new
    
    round.confirmed.should == false
  end
  
  it "minimum people should be less than maximum" do
    @round.min_people = 2
    @round.max_people = 1
    
    @round.should be_invalid
  end
  
  it "people should not be less than 2" do
    @round.min_people = 1
    @round.max_people = 1
    
    @round.should be_invalid
  end
  
  it "minimum people should be numeric" do
    @round.should validate_numericality_of(:min_people)
  end
  
  it "maximum people should be numeric" do
    @round.should validate_numericality_of(:max_people)
  end
  
  it "minimum people should not be fractional" do
    @round.min_people = 0.5
    
    @round.should be_invalid
  end
  
  it "maximum people should not be fractional" do
    @round.max_people = 0.5
    
    @round.should be_invalid
  end
  
  it "deadline should be before or at the same time of date" do
    @round.deadline = 1.hour.since(@round.date)
    
    @round.should be_invalid
    @round.errors[:deadline].include?("must be earlier than date").should == true
  end
  
  it "deadline should not be before now" do
    @round.deadline = Time.now - 1.day
    
    @round.should be_invalid
  end
  
  it "date should not be before now" do
    @round.date = Time.now - 1.day
    
    @round.should be_invalid
  end
  
  it "deadline and date should be equal on creation" do
    @round.date.should == @round.deadline
  end
  
  # attributes accessibility tests
  
  it "should not be able to mass-assign user_id" do
    @round.should_not allow_mass_assignment_of(:user_id)
  end
  
  it "should be able to mass-assign deadline" do
    @round.should allow_mass_assignment_of(:deadline)
  end
  
  it "should be able to mass-assign date" do
    @round.should allow_mass_assignment_of(:date)
  end
  
  it "should be able to mass-assign max_people" do
    @round.should allow_mass_assignment_of(:max_people)
  end
  
  it "should be able to mass-assign min_people" do
    @round.should allow_mass_assignment_of(:min_people)
  end
  
  it "should be able to mass-assign arena_id" do
    @round.should allow_mass_assignment_of(:arena_id)
  end
  
  it "should be able to mass-assign game_id" do
    @round.should allow_mass_assignment_of(:game_id)
  end
  
  it "should be able to mass-assign description" do
    @round.should allow_mass_assignment_of(:description)
  end
  
  # associations tests
  
  it "should belong to an arena" do
    @round.should belong_to(:arena)
  end
  
  it "should belong to a game" do
    @round.should belong_to(:game)
  end
 
  it "rounds should have many subscriptions" do
    @round.should have_many(:subscriptions)
  end
  
  it "should belong to user" do
    @round.should belong_to(:user)
  end
  
  it "should have many comments" do
    @round.should have_many(:comments)
  end
  
  it "should have many subscribers through subscriptions" do
    @round.should have_many(:subscribers).through(:subscriptions)
  end
  
  # methods tests
  
  it "should be full when subscribers are equal to max_people" do
    @round.save!
    
    @round.full?.should == false
    @round.remaining_spots.times do
      Factory(:subscription, :round => @round)
    end
    @round.reload
    
    @round.full?.should == true
  end
  
  it "confirmable? should return the expected value" do
    @round.date = Time.now + 2.month
    
    @round.confirmable?.should == true
    
    @round.deadline = Time.now + 1.month
    
    @round.confirmable?.should == false
  end
  
  it "should confirm if can confirm" do
    @round.date = Time.now + 2.month
    
    @round.confirmed.should == false
    @round.confirm!.should == true
    @round.confirmed.should == true
  end
  
  it "should not confirm if the round is already confirmed" do
    @round.date = Time.now + 2.month
    @round.save!
    @round.confirm!
    
    @round.confirmed.should == true
    @round.confirm!.should == false 
    @round.confirmed.should == true
  end
  
  it "authorized? should return the expected value" do
    @round.authorized?(@round.user).should == true
    
    @round.authorized?(mock_model('User')).should == false
  end
  
  it "all subscribers should include the owner" do
    @round.all_subscribers.include?(@round.user).should == true
  end
  
  it "all subscribers should include a subscriber" do
    @round.save!

    @subscription = Factory :subscription, :round => @round
    @round.reload
 
    @round.subscribers.include?(@subscription.user).should == true
  end
  
  it "should decrease remaining spots when someone subscribes" do
    @round.save!
    
    previous_remaining_spots = @round.remaining_spots
    @subscription = Factory :subscription, :round => @round
    @round.reload
    
    @round.remaining_spots.should be_one_less_than(previous_remaining_spots)
  end
  
  it "should send emails to subscribers when the owner of the round confirms" do
    @round.date = Time.now + 2.month
    @round.save!
    
    5.times { @subscription = Factory :subscription, :round => @round }
    @round.confirm!
    @round.subscribers.each do |subscriber|
      @round.should have_sent_email.with_subject(/Round confirmation/).from('info@playround.com').with_body(/Hello/).to(subscriber.email)
    end
  end
  
  # ability tests
  
  it "only the user who created the round should be able to manage it" do
    @round.save!
    
    @round.authorized?(@round.user).should == true
    
    @round.authorized?(Factory :user).should == false
  end
  
  it "user can create rounds" do
    ability = Ability.new Factory :user
    ability.can?(:create, Round).should == true
  end
  
  it "guests can't create rounds" do
    ability = Ability.new User.new
    ability.cannot?(:create, Round).should == true
  end
  
  it "anyone can read any round" do
    ability = Ability.new Factory :user
    ability.can?(:read, @round).should == true
    ability = Ability.new @round.user
    ability.can?(:read, @round).should == true
    ability = Ability.new User.new
    ability.can?(:read, @round).should == true
  end
  
  it "user can only update rounds which he owns" do
    @round.date = Time.now + 2.months
    @round.deadline = Time.now + 1.month
    @round.save!
    
    ability = Ability.new @round.user
    ability.can?(:update, @round).should == true
    ability.cannot?(:update, Factory.build(:round)).should == true
  end
  
  it "user can only destroy rounds which he owns and that has no subscribers" do
    ability = Ability.new @round.user
    ability.can?(:destroy, @round).should == true
    ability.cannot?(:destroy, Factory.build(:round)).should == true
    
    @round.save!
    Factory :subscription, :round => @round
    
    ability.cannot?(:destroy, @round).should == true
  end
  
  it "user can only update rounds before the deadline" do
    ability = Ability.new @round.user
    @round.date = Time.now + 1.second
    @round.deadline = Time.now
    @round.save!

    Time.stub(:now).and_return(@round.deadline + 10.seconds)
    ability.cannot?(:update, @round).should == true
    Time.unstub!(:now)
  end
end