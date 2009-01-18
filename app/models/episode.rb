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

class Episode < Book
  belongs_to :series
  
  has_permalink [:series_name, :number]
  
  validates_presence_of :series_id, :number
  validates_associated  :series
  validates_numericality_of :number  
  validates_uniqueness_of :permalink
  
  after_validation :copy_publisher
  
  # make sure the given numbered episode of the series doesn't already exist
  def validate
    if self.new_record? and self.series and self.number
      self.errors.add(:number, "is already taken") unless self.series.find_episode(self.number).nil?
    end
  end
  
  def to_param
    number.to_s # only ever accessed via nested routes (from series controller)
  end
  
  # required for creating permalink, returns series name from association
  def series_name
    series.name.nil? ? nil : series.name
  end
  
  # override name to be the series name + the episode number
  def name
    "#{series_name} \##{number}"
  end
    
  private
  
    # copy the publisher from the series
    def copy_publisher
      self.publisher_id = self.series.publisher_id
    end
end
