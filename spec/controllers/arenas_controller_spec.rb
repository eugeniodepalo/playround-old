require 'spec_helper'

describe ArenasController do
  before(:each) do
    @arena = FactoryGirl.build :arena
    @valid_attributes = @arena.attributes.select{ |k,v| Arena.accessible_attributes.include?(k.to_sym) }
    sign_in_as @arena.user
  end
  
  # RESTful methods tests
  
  it "should get index" do
    @arena.save!
    get :index
    
    should respond_with(:success)
    assigns(:arenas).should_not be_nil
  end

  it "should get new" do
    get :new
    
    should respond_with(:success)
  end
  
  it "should not get new if guest" do
    sign_out
    
    get :new
    
    should redirect_to(sign_in_url)
  end

  it "should create arena" do
    Proc.new do
      post :create, :arena => @valid_attributes
    end.should change(Arena, :count).by(1)

    should respond_with(:found)
    should redirect_to(arena_path(assigns(:arena)))
  end
  
  it "should not create arena if guest" do
    sign_out
    
    post :create, :arena => @valid_attributes
    
    should redirect_to(sign_in_url)
  end

  it "should always show arenas" do
    @arena.save!
    get :show, :id => @arena.to_param
    
    should respond_with(:success)
    
    arena = FactoryGirl.create :arena, :public => true
    
    get :show, :id => arena.to_param
    
    should respond_with(:success)
    
    sign_out
    
    get :show, :id => @arena.to_param
    
    should respond_with(:success)
  end

  it "should get edit if you own the arena" do
    @arena.save!
    get :edit, :id => @arena.to_param
    
    should respond_with(:success)
  end

  it "should not get edit if you don't own the arena" do
    get :edit, :id => FactoryGirl.create(:arena).to_param
    
    should redirect_to(sign_in_url)
  end
  
  it "should not get edit if guest" do
    @arena.save!
    sign_out
    
    get :edit, :id => @arena.to_param
    
    should redirect_to(sign_in_url)
  end

  it "should update if you own the arena" do
    @arena.save!
    put :update, :id => @arena.to_param, :arena => @valid_attributes
    
    should respond_with(:found)
    should redirect_to(arena_path(assigns(:arena)))
  end
  
  it "should not update if you don't own the arena" do
    arena = FactoryGirl.create :arena
    put :update, :id => arena.to_param, :arena => arena.attributes
    
    should redirect_to(sign_in_url)
  end
  
  it "should not update if guest" do
    @arena.save!
    sign_out
    
    put :update, :id => @arena.to_param, :arena => @arena.attributes
    
    should redirect_to(sign_in_url)
  end

  it "should destroy if you own the arena" do
    @arena.save!

    Proc.new do
      delete :destroy, :id => @arena.to_param
    end.should change(Arena, :count).by(-1)
    
    should respond_with(:found)
    should redirect_to(arenas_path)
  end
  
  it "should not destroy if you don't own the arena" do
    delete :destroy, :id => FactoryGirl.create(:arena).to_param
    
    should redirect_to(sign_in_url)
  end
  
  it "should not destroy if there is at least one round with that arena" do
    @arena.save!
    FactoryGirl.create :round, :arena => @arena
    
    delete :destroy, :id => @arena.to_param
    
    should redirect_to(arena_path(@arena))
  end
  
  it "should not destroy if guest" do
    @arena.save!
    sign_out
    
    delete :destroy, :id => @arena.to_param
    
    should redirect_to(sign_in_url)
  end
  
  # ability tests
  
  it "user can create arenas" do
    ability = Ability.new FactoryGirl.create :user
    ability.should be_able_to(:create, Arena)
  end
  
  it "guests can't create arenas" do
    ability = Ability.new User.new
    ability.should_not be_able_to(:create, Arena)
  end
  
  it "anyone can read any arena" do
    @arena.save!
    ability = Ability.new FactoryGirl.create :user
    ability.should be_able_to(:read, @arena)
    ability = Ability.new @arena.user
    ability.should be_able_to(:read, @arena)
    ability = Ability.new User.new
    ability.should be_able_to(:read, @arena)
  end
  
  it "user can only update arenas which he owns" do
    @arena.save!
    ability = Ability.new @arena.user
    ability.should be_able_to(:update, @arena)
    ability.should_not be_able_to(:update, FactoryGirl.build(:arena))
  end
  
  it "user can only destroy arenas which he owns" do
    @arena.save!
    ability = Ability.new @arena.user
    ability.should be_able_to(:destroy, @arena)
    ability.should_not be_able_to(:destroy, FactoryGirl.build(:arena))
  end
end