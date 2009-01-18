# == Schema Information
# Schema version: 20
#
# Table name: books
#
#  id           :integer(11)   not null, primary key
#  number       :integer(11)   
#  series_id    :integer(11)   
#  created_at   :datetime      
#  updated_at   :datetime      
#  published_on :datetime      
#  description  :text          
#  type         :string(255)   
#  name         :string(255)   
#  permalink    :string(255)   
#  publisher_id :integer(11)   
#  talent       :string(255)   
#

class Book < ActiveRecord::Base
  acts_as_rateable
  
  belongs_to :publisher
  
  has_one :cover_image, :dependent => :destroy
  
  has_many :comments,
           :dependent => :destroy,
           :order => "created_at",
           :extend => PaginationExtension
           
  has_and_belongs_to_many :users # collection
  
  attr_protected :permalink
  
  before_save :clean_data
  
  # Is this book part of a larger series?
  def episode?
    self.class == Episode
  end

  # render description as textile (use .to_html to convert for display)
  def description
    #RedCloth.new(read_attribute(:description), [:hard_breaks])
    RedCloth.new(read_attribute(:description) || "")
  end

  # render talent as textile (use .to_html to convert for display)
  def talent
    RedCloth.new(read_attribute(:talent) || "")
  end
  
  private
  
    def clean_data
      self.description = strip_html(self.description)
      self.talent = strip_html(self.talent)
    end
    
    # strip/convert html and extraneous data from release listings
    def strip_html(str)
      str.gsub(/<a .*>/, "") \
         .gsub(/<\/a ?>/, "") \
         .gsub(/<br ?\/?>/, "\n") \
         .gsub(/<\/?[^>]*>/, "") \
         .gsub(/&nbsp;/, " ") \
         .gsub(/&lt;/, "<") \
         .gsub(/&gt;/, ">") \
         .gsub(/&amp;/, "&") \
         .gsub(/\222/, "'") \
         .gsub(/&#226;/, " - ") \
         .gsub(/--/,  "-")
    end
end
