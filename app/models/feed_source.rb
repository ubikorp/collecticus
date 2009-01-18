# == Schema Information
# Schema version: 20
#
# Table name: feed_sources
#
#  id         :integer(11)   not null, primary key
#  name       :string(255)   
#  url        :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class FeedSource < ActiveRecord::Base
  has_many :feed_articles
  
  validates_presence_of :name, :url
  validates_uniqueness_of :name, :url
  
  def recent_articles(limit = 5)
    feed_articles.find(:all, :order => "published_at DESC", :limit => limit)
  end  
end
