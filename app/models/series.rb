# == Schema Information
# Schema version: 20
#
# Table name: series
#
#  id           :integer(11)   not null, primary key
#  name         :string(255)   
#  permalink    :string(255)   
#  publisher_id :integer(11)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Series < ActiveRecord::Base
  belongs_to :publisher
  
  has_many   :episodes,
             :dependent => :destroy,
             :order => "number",
             :extend => [PaginationExtension, CollectedByExtension]
  
  validates_presence_of   :publisher_id, :name
  validates_associated    :publisher
  validates_uniqueness_of :name, :case_sensitive => false
  
  has_permalink :name
  
  attr_protected :permalink
  
  def to_param
    permalink
  end

  # return the episode from this series with the appropriate number (or nil)
  def find_episode(number)
    self.episodes.find_by_number(number)
  end
  
  # return the most recently published episode of the series
  def latest_episode
    self.episodes.find(:first, :conditions => "published_on <= NOW()", :order => "published_on DESC")
  end

  # determine the average rating of this series from all episode ratings
  def rating
    self.episodes.average(:rating, 
                          :joins => "LEFT JOIN ratings on books.id = ratings.rateable_id", 
                          :conditions => "ratings.rateable_type = 'Book'")
  end

  # return the top rated series
  def self.top_rated(limit = 5)
    find(:all,
      :select => "DISTINCT series.*, avg(ratings.rating) AS rating, count(ratings.rating) AS votes",  
      :joins => "LEFT JOIN books ON series.id = books.series_id LEFT JOIN ratings ON books.id = ratings.rateable_id",  
      :conditions => "ratings.rateable_type = 'Book'",  
      :group => "series.id",  
      :order => "rating DESC, votes DESC",  
      :limit => limit)
  end
end
