# == Schema Information
# Schema version: 20
#
# Table name: cover_images
#
#  id           :integer(11)   not null, primary key
#  book_id      :integer(11)   
#  parent_id    :integer(11)   
#  content_type :string(255)   
#  filename     :string(255)   
#  thumbnail    :string(255)   
#  size         :integer(11)   
#  width        :integer(11)   
#  height       :integer(11)   
#

class CoverImage < ActiveRecord::Base
  belongs_to :book
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :path_prefix => 'public/images/art',
                 :max_size => 500.kilobytes,
                 :resize_to => '400x600>',
                 :thumbnails => { :sm => '40x60>', :md => '80x120>', :lg => '120x180>' }

  validates_as_attachment
  
  validates_presence_of :book_id
  validates_associated  :book
  
  # Set extra values in the thumbnail class as we want it to have the same 
  # additional attribute values as the original image
  before_thumbnail_saved do |record, thumbnail|
    thumbnail.book_id = record.book_id
  end

end
