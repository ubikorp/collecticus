require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users, :ratings, :books

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
  
  def test_average_rating
    assert_equal users(:quentin).average_rating, Rating.average(:rating, :conditions => "user_id = #{users(:quentin).id}")
  end
  
  def test_recent_ratings
    assert_equal users(:quentin).recent_ratings(5).length,
      [Rating.find(:all, :conditions => "user_id=#{users(:quentin).id}",
        :order => "created_at DESC", :limit => 5).length, 5].min
    assert_equal users(:quentin).recent_ratings(1)[0],
      Rating.find(:first, :conditions => "user_id=#{users(:quentin).id}",
        :order => "created_at DESC")
  end
  
  def test_recent_comments
    assert_equal users(:quentin).recent_comments(5).length,
      [users(:quentin).comments.find(:all, :order => "created_at DESC",
        :limit => 5).length, 5].min
    assert_equal users(:quentin).recent_comments(1)[0],
      users(:quentin).comments.find(:first, :order => "created_at DESC")
  end
  
  def test_series
    assert_equal users(:quentin).series.length,
      Series.count(:joins => "LEFT JOIN books ON books.series_id = series.id LEFT JOIN books_users ON books_users.book_id = books.id",
                   :group => "series.id", :conditions => "books_users.user_id = #{users(:quentin).id}").length
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
