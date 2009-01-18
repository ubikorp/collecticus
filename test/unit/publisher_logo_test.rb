require File.dirname(__FILE__) + '/../test_helper'

class PublisherLogoTest < Test::Unit::TestCase
  fixtures :publisher_logos, :publishers

  def test_create_image
    assert_difference PublisherLogo, :count do
      image = create_image
      assert !image.new_record?, "#{image.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_publisher
    assert_no_difference PublisherLogo, :count do
      image = create_image(:publisher => nil)
      assert image.errors.on(:publisher_id)
    end
  end

  def test_invalid_content_type
    assert_no_difference PublisherLogo, :count do
      image = create_image(:uploaded_data => fixture_file_upload("images/rails.png", 'text/pdf'))
      assert_equal image.errors.on(:content_type), "is not included in the list"
    end
  end

  protected
  
    def create_image(options = {})
      PublisherLogo.create({ :uploaded_data => fixture_file_upload("images/rails.png", 'image/jpeg'),
                             :publisher => publishers(:dc) }.merge(options))
    end
end
