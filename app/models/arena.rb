class Arena < ActiveRecord::Base
  attr_accessible :name, :latitude, :longitude, :website
  
  has_many :rounds
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :latitude
  validates_presence_of :longitude
  validates_presence_of :user_id
  
  validates_length_of :name, :in => 3..30
  
  validates_numericality_of :latitude, :greater_than_or_equal_to => -90, :less_than_or_equal_to => 90
  validates_numericality_of :longitude, :greater_than_or_equal_to => -180, :less_than_or_equal_to => 180
  
  validates_url_format_of :website, :allow_blank => true
  adjusts_string :website, :prepend => 'http://', :if => Proc.new { |a| !(a.website =~ /^.*:.*$/) }
  
  reverse_geocoded_by :latitude, :longitude
end
