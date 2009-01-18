# == Schema Information
# Schema version: 20
#
# Table name: feed_articles
#
#  id             :integer(11)   not null, primary key
#  feed_source_id :integer(11)   
#  title          :string(255)   
#  created_at     :datetime      
#  published_at   :datetime      
#  author         :string(255)   
#  link           :string(255)   
#  content        :text          
#  category       :string(255)   
#

class FeedArticle < ActiveRecord::Base
  belongs_to :feed_source
  
  validates_presence_of :title, :published_at, :link, :feed_source_id
  validates_uniqueness_of :title, :link
  validates_associated :feed_source
  
  # NOTE: exclude our own blog feed from this list (id is 1)
  def self.recent_articles(limit = 10)
    self.find(:all, :conditions => "feed_source_id != 1", :order => "published_at DESC", :limit => limit)
  end
end
