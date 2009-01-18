require File.dirname(__FILE__) + '/../test_helper'

class PublisherTest < Test::Unit::TestCase
  fixtures :publishers

  def test_should_create_publisher
    assert_difference Publisher, :count do
      publisher = create_publisher
      assert !publisher.new_record?, "#{publisher.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference Publisher, :count do
      publisher = create_publisher(:name => nil)
      assert publisher.errors.on(:name)
    end
  end

  def test_should_require_unique_name
    assert_no_difference Publisher, :count do
      publisher = create_publisher(:name => publishers(:marvel).name)
      assert publisher.errors.on(:name)
    end
  end
  
  def test_should_create_permalink
    assert_equal PermalinkFu.escape('new publisher'), create_publisher.permalink
  end
  
  def test_latest_solobook
    assert_equal publishers(:marvel).latest_solobook, SoloBook.find(:first, 
      :conditions => ["publisher_id = ? AND published_on <= NOW()", publishers(:marvel).id], 
      :order => "published_on DESC")
  end
  
  protected
    def create_publisher(options = {})
      Publisher.create({ :name => 'new publisher' }.merge(options))
    end
end
