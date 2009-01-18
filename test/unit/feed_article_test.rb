require File.dirname(__FILE__) + '/../test_helper'

class FeedArticleTest < Test::Unit::TestCase
  fixtures :feed_articles, :feed_sources

  def test_should_create_feed_article
    assert_difference FeedArticle, :count do
      feed_article = create_feed_article
      assert !feed_article.new_record?, "#{feed_article.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_title
    assert_no_difference FeedArticle, :count do
      feed_article = create_feed_article(:title => nil)
      assert feed_article.errors.on(:title)
    end
  end

  def test_should_require_unique_title
    assert_no_difference FeedArticle, :count do
      feed_article = create_feed_article(:title => feed_articles(:collecticus_welcome).title)
      assert feed_article.errors.on(:title)
    end
  end
  
  def test_should_require_link
    assert_no_difference FeedArticle, :count do
      feed_article = create_feed_article(:link => nil)
      assert feed_article.errors.on(:link)
    end
  end

  def test_should_require_unique_link
    assert_no_difference FeedArticle, :count do
      feed_article = create_feed_article(:link => feed_articles(:collecticus_welcome).link)
      assert feed_article.errors.on(:link)
    end
  end
  
  def test_should_require_published_at
    assert_no_difference FeedArticle, :count do
      feed_article = create_feed_article(:published_at => nil)
      assert feed_article.errors.on(:published_at)
    end
  end
  
  def test_should_require_feed_source
    assert_no_difference FeedArticle, :count do
      feed_article = create_feed_article(:feed_source_id => nil)
      assert feed_article.errors.on(:feed_source_id)
    end
  end
  
  protected
    def create_feed_article(options = {})
      FeedArticle.create({ :title => 'news!', :link => 'http://info.collectic.us/articles/3', :feed_source_id => feed_sources(:collecticus).id, :published_at => "#{Time.now}" }.merge(options))
    end
end
