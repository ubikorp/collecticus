require File.dirname(__FILE__) + '/../test_helper'

class BookTest < Test::Unit::TestCase
  fixtures :books

  def test_should_create_book
    assert_difference Book, :count do
      book = Book.create(:name => "blah blah blah")
      assert !book.new_record?, "#{book.errors.full_messages.to_sentence}"
    end
  end
  
  def test_episode
    assert Book.find(books(:green_lantern_21).id).episode?
    assert !Book.find(books(:the_trials_of_shazam_vol_1).id).episode?
  end
  
  def test_description_redcloth
    assert_equal RedCloth, books(:green_lantern_21).description.class
  end
  
  def test_talent_redcloth
    assert_equal RedCloth, books(:green_lantern_21).talent.class
  end
end
