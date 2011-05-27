require 'test_helper'

class GameTest < ActiveSupport::TestCase
  def setup
    @game = Factory.build :game
  end
  
  def teardown
    @game = nil
  end

  
  test "factory should be valid" do
    assert @game.valid?
  end
  
  test "should not be valid wihout a name" do
    @game.name = nil
    
    assert @game.invalid?
  end
  
  test "should not be valid without a description" do
    @game.description = nil
    
    assert @game.invalid?
  end
  
  test "name should not be more than 30 characters" do
    @game.name = 'a' * 35
    
    assert @game.invalid?
  end
  
  test "website should be a valid url" do
    assert_validates_url @game
  end
  
  test "website should be prefixed with the default schema if not present" do
    assert_adjusts_url @game
  end
  
  test "record should be valid when website is blank" do
    @game.website = ''
    
    assert @game.valid?
  end
  
  test "record should be valid when website is nil" do
    @game.website = nil
    
    assert @game.valid?
  end
  
  test "should have many rounds" do
    @game.save!
    
    assert_has_many @game, :rounds
  end
  
  test "should belong to user" do
    assert_belongs_to @game, :user
  end
  
  test "should be invalid without a user" do
    @game.user = nil
    
    assert @game.invalid?
  end
  
  test "any user can create games" do
    ability = Ability.new Factory :user
    assert ability.can?(:create, Game)
  end
  
  test "user can read any game" do
    ability = Ability.new Factory :user
    assert ability.can?(:read, @game)
    ability = Ability.new @game.user
    assert ability.can?(:read, @game)
  end
  
  test "user can only update games which he owns" do
    ability = Ability.new @game.user
    assert ability.can?(:update, @game)
    assert ability.cannot?(:update, Factory.build(:game))
  end
  
  test "user can only destroy games which he owns" do
    ability = Ability.new @game.user
    assert ability.can?(:destroy, @game)
    assert ability.cannot?(:destroy, Factory.build(:game))
  end
end