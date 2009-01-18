require File.dirname(__FILE__) + '/../test_helper'

class SoloBookTest < Test::Unit::TestCase
  fixtures :books, :publishers

  def test_should_create_book
    assert_difference SoloBook, :count do
      book = create_book
      assert !book.new_record?, "#{book.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference SoloBook, :count do
      book = create_book(:name => nil)
      assert book.errors.on(:name)
    end
  end
  
  def test_should_require_unique_name
    assert_no_difference SoloBook, :count do
      book = create_book(:name => books(:the_trials_of_shazam_vol_1).name)
      assert book.errors.on(:name)
    end
  end

  def test_should_require_publisher
    assert_no_difference SoloBook, :count do
      book = create_book(:publisher => nil)
      assert book.errors.on(:publisher_id)
    end
  end
  
  def test_permalink
    book = create_book
    assert_equal book.permalink, PermalinkFu.escape(book.name)
  end

  def test_to_param
    book = books(:the_trials_of_shazam_vol_1)
    assert_equal book.to_param, book.permalink
  end
  
  protected
    def create_book(options = {})
      SoloBook.create({ :name => "Blah Blah Blah Trade Paperback Vol. 1",
                        :publisher => Publisher.find(:first) }.merge(options))
    end
end
