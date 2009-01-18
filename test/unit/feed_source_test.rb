require File.dirname(__FILE__) + '/../test_helper'

class FeedSourcetest < Test::Unit::TestCase
  fixtures :feed_sources, :feed_articles

  def test_should_create_feed_source
    assert_difference FeedSource, :count do
      feed_source = create_feed_source
      assert !feed_source.new_record?, "#{feed_source.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference FeedSource, :count do
      feed_source = create_feed_source(:name => nil)
      assert feed_source.errors.on(:name)
    end
  end

  def test_should_require_unique_name
    assert_no_difference FeedSource, :count do
      feed_source = create_feed_source(:name => feed_sources(:comicbloc).name)
      assert feed_source.errors.on(:name)
    end
  end
  
  def test_should_require_url
    assert_no_difference FeedSource, :count do
      feed_source = create_feed_source(:url => nil)
      assert feed_source.errors.on(:url)
    end
  end

  def test_should_require_unique_url
    assert_no_difference FeedSource, :count do
      feed_source = create_feed_source(:url => feed_sources(:comicbloc).url)
      assert feed_source.errors.on(:url)
    end
  end
  
  protected
    def create_feed_source(options = {})
      FeedSource.create({ :name => 'new feed_source', :url => 'http://www.example.com' }.merge(options))
    end
end
