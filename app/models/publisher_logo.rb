# == Schema Information
# Schema version: 20
#
# Table name: publisher_logos
#
#  id           :integer(11)   not null, primary key
#  publisher_id :integer(11)   
#  parent_id    :integer(11)   
#  content_type :string(255)   
#  filename     :string(255)   
#  thumbnail    :string(255)   
#  size         :integer(11)   
#  width        :integer(11)   
#  height       :integer(11)   
#

class PublisherLogo < ActiveRecord::Base
  belongs_to :publisher
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :path_prefix => 'public/images/logos',
                 :max_size => 500.kilobytes
                 
  validates_as_attachment
  
  validates_presence_of :publisher_id
  validates_associated  :publisher
end
