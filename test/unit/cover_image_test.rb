require File.dirname(__FILE__) + '/../test_helper'

class CoverImageTest < Test::Unit::TestCase
  fixtures :cover_images, :books, :series
  
  def test_create_image
    assert_difference CoverImage, :count, 4 do
      image = create_image
      assert !image.new_record?, "#{image.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_book
    assert_no_difference CoverImage, :count do
      image = create_image(:book => nil)
      assert image.errors.on(:book_id)
    end
  end

  def test_create_image_with_thumbnail
    assert_difference CoverImage, :count, 4 do
      count = CoverImage.count
      image = create_image
      assert_equal count + 4, CoverImage.count
      assert_equal 3, image.thumbnails.length
    end
  end
  
  def test_invalid_content_type
    assert_no_difference CoverImage, :count do
      image = create_image(:uploaded_data => fixture_file_upload("images/rails.png", 'text/pdf'))
      assert_equal image.errors.on(:content_type), "is not included in the list"
    end
  end

  protected
  
    def create_image(options = {})
      CoverImage.create({ :uploaded_data => fixture_file_upload("images/rails.png", 'image/jpeg'),
                          :book => books(:green_lantern_21) }.merge(options))
    end
end
