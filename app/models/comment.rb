# == Schema Information
# Schema version: 20
#
# Table name: comments
#
#  id         :integer(11)   not null, primary key
#  book_id    :integer(11)   
#  user_id    :integer(11)   
#  body       :text          
#  created_at :datetime      
#  updated_at :datetime      
#

class Comment < ActiveRecord::Base
  belongs_to :book
  belongs_to :user
  
  validates_presence_of :book_id, :user_id, :body
  validates_associated  :book, :user
  
  # render description as textile (use .to_html to convert for display)
  def body
    RedCloth.new(read_attribute(:body) || "").strip.gsub(/\n/, "<br/>")
  end
  
  # return the (globally) most recent comments
  def self.most_recent(limit = 5)
    find(:all, :order => "created_at DESC", :limit => limit)
  end
end
