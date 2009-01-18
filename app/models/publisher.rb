# == Schema Information
# Schema version: 20
#
# Table name: publishers
#
#  id         :integer(11)   not null, primary key
#  name       :string(255)   
#  permalink  :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Publisher < ActiveRecord::Base
  has_many :series,
           :dependent => :destroy,
           :order => "name",
           :extend => [PaginationExtension, CollectedByExtension]
           
  has_many :books,
           :dependent => :destroy,
           :order => "name",
           :extend => [PaginationExtension, CollectedByExtension]
           
  has_many :solobooks,
           :class_name => "SoloBook",
           :table_name => "books",
           :foreign_key => "publisher_id",
           :order => "name",
           :extend => [PaginationExtension, CollectedByExtension]
           
  has_many :episodes,
           :class_name => "Episode",
           :table_name => "books",
           :foreign_key => "publisher_id",
           :order => "name",
           :extend => [PaginationExtension, CollectedByExtension]
           
  has_one  :publisher_logo
  
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  has_permalink :name
  
  attr_protected :permalink
  
  def to_param
    permalink
  end
  
  # return the most recently published solobook
  def latest_solobook
    self.solobooks.find(:first, 
                        :conditions => "published_on <= NOW()", 
                        :order => "published_on DESC")
  end
end
