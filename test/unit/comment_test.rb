require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :books, :users, :series, :publishers

  def test_should_create_comment
    assert_difference Comment, :count do
      comment = create_comment
      assert !comment.new_record?, "#{comment.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_book
    assert_no_difference Comment, :count do
      comment = create_comment(:book => nil)
      assert comment.errors.on(:book_id)
    end
  end
  
  def test_should_require_user
    assert_no_difference Comment, :count do
      comment = create_comment(:user => nil)
      assert comment.errors.on(:user_id)
    end
  end
  
  def test_should_require_body
    assert_no_difference Comment, :count do
      comment = create_comment(:body => nil)
      assert comment.errors.on(:body)
    end
  end
  
  def test_most_recent
    assert_equal Comment.most_recent[0], Comment.find(:first, :order => "created_at DESC")
  end
  
  def test_talent_redcloth
    assert_equal RedCloth, comments(:green_lantern_21_aaron).body.class
  end
  
  protected
  
    def create_comment(options = {})
      Comment.create({:book => books(:green_lantern_21), :user => users(:aaron),
                      :body => 'body'}.merge(options))
    end
end
