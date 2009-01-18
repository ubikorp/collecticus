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

class SoloBook < Book
  has_permalink :name
  
  validates_presence_of :publisher_id, :name
  validates_associated  :publisher
  validates_uniqueness_of :name, :permalink
  
  def to_param
    permalink
  end
end

