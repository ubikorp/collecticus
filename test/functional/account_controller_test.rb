require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  fixtures :users, :books, :series, :ratings, :comments, :publishers, :books_users
  
  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_valid_markup
    login_as(:quentin)
    get :new; assert_valid_markup
    get :show; assert_valid_markup
    get :edit; assert_valid_markup
    get :pulls; assert_valid_markup
  end
  
  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_show_preferences_should_redirect_if_not_logged_in
    get :show
    assert_response :redirect
    assert_redirected_to :controller => 'session', :action => 'new'
  end
  
  def test_should_show_preferences
    login_as(:quentin)
    get :show
    assert_response :success
    assert_template 'show'
  end
  
  def test_edit_preferences_should_redirect_if_not_logged_in
    get :edit
    assert_response :redirect
    assert_redirected_to :controller => 'session', :action => 'new'
  end
  
  def test_should_edit_preferences
    login_as(:quentin)
    get :edit
    assert_response :success
    assert_template 'edit'
  end
  
  def test_should_update_preferences
    login_as(:quentin)
    put :update, :user => { :bio => "I am a lonesome prairie dog." }
    assert_response :redirect
    assert_redirected_to :action => 'show'
  end
  
  def test_update_preferences_should_redirect_if_not_logged_in
    put :update
    assert_response :redirect
    assert_redirected_to :controller => 'session', :action => 'new'
  end
  
  def test_current_pull_list
    login_as(:quentin)
    get :pulls
    assert_response :success
    assert_template 'pulls'

    comic_book_day = Time.now.beginning_of_week + 2.days
    releases = []
    0.upto(9) do |i|
      releases << users(:quentin).books.by_week(comic_book_day + i.week)
    end
    
    assert_select "div.release-date", releases.size
    assert_select "div.release-date > table > tr.book-table-row", :value => /#{releases.flatten[0].name}/
  end
  
  def test_prev_pull_list
    login_as(:quentin)
    get :pulls, :prev => 1
    assert_response :success
    assert_template 'pulls'
    
    comic_book_day = Time.now.beginning_of_week - 5.days
    releases = []
    0.upto(9) do |i|
      releases << users(:quentin).books.by_week(comic_book_day - i.week)
    end
    
    assert_select "div.release-date", releases.size
    assert_select "div.release-date > table > tr.book-table-row", :value => /#{releases.flatten[0].name}/
  end
  
  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
