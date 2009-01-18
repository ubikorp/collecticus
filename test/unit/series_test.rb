require File.dirname(__FILE__) + '/../test_helper'

class SeriesTest < Test::Unit::TestCase
  fixtures :series, :publishers, :books, :ratings

  def test_should_create_series
    assert_difference Series, :count do
      series = create_series
      assert !series.new_record?, "#{series.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference Series, :count do
      series = create_series(:name => nil)
      assert series.errors.on(:name)
    end
  end

  def test_should_require_unique_name
    assert_no_difference Series, :count do
      series = create_series(:name => series(:action_comics).name)
      assert series.errors.on(:name)
    end
  end
  
  def test_should_require_publisher
    assert_no_difference Series, :count do
      series = create_series(:publisher_id => nil)
      assert series.errors.on(:publisher_id)
    end
  end
  
  def test_should_create_permalink
    assert_equal PermalinkFu.escape('new series'), create_series.permalink
  end
  
  def test_find_episode
    assert_not_nil series(:action_comics).find_episode(series(:action_comics).episodes.find(:first).number)
    assert_nil series(:action_comics).find_episode(2000)
  end
  
  def test_latest_episode
    assert_equal series(:action_comics).latest_episode, Episode.find(:first, 
      :conditions => ["series_id = ? AND published_on <= NOW()", series(:action_comics).id], 
      :order => "published_on DESC")
  end
  
  def test_rating
    assert_equal series(:green_lantern).rating, Episode.average(:rating,
      :joins => "LEFT JOIN ratings on books.id = ratings.rateable_id", 
      :conditions => ["ratings.rateable_type = 'Book' AND books.series_id = ?", series(:green_lantern).id])
  end
  
  def test_top_rated
    assert_equal Series.top_rated(1)[0].name, series(:green_lantern).name
  end
  
  protected
    def create_series(options = {})
      Series.create({ :name => 'new series', :publisher => Publisher.find(:first) }.merge(options))
    end
end
