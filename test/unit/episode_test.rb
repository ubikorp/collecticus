require File.dirname(__FILE__) + '/../test_helper'

class EpisodeTest < Test::Unit::TestCase
  fixtures :books, :series

  def test_should_create_episode
    assert_difference Episode, :count do
      episode = create_episode
      assert !episode.new_record?, "#{episode.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_number
    assert_no_difference Episode, :count do
      episode = create_episode(:number => nil)
      assert episode.errors.on(:number)
    end
  end
  
  def test_should_require_numerical_number
    assert_no_difference Episode, :count do
      episode = create_episode(:number => 'explosivo!')
      assert episode.errors.on(:number)
    end
  end

  def test_should_require_unique_series_number
    assert_no_difference Episode, :count do
      episode = create_episode(:series => series(:wolverine), :number => series(:wolverine).episodes.find(:first).number)
      assert episode.errors.on(:number)
    end
  end
  
  def test_series_name
    episode = books(:green_lantern_21)
    assert_equal episode.series_name, episode.series.name
  end
  
  def test_name
    episode = books(:green_lantern_21)
    assert_equal "#{episode.series.name} \##{episode.number}", episode.name
  end
  
  def test_permalink
    episode = books(:green_lantern_21)
    assert_equal "#{episode.series.permalink}-#{episode.number}", episode.permalink
  end
    
  def test_to_param
    episode = create_episode
    assert_equal episode.to_param, episode.number.to_s # doesn't need to be globally unique
  end
  
  protected
    def create_episode(options = {})
      Episode.create({ :series => Series.find(:first), :number => 1000 }.merge(options))
    end
end
