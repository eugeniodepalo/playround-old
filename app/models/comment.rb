class Comment < ActiveRecord::Base
  attr_accessible :text, :round_id
  
  belongs_to :user
  belongs_to :round
  
  validates_presence_of :text
  validates_presence_of :user_id
  validates_presence_of :round_id
end
