require File.dirname(__FILE__) + '/../test_helper'
require 'publishers_controller'

# Re-raise errors caught by the controller.
class PublishersController; def rescue_action(e) raise e end; end

class PublishersControllerTest < Test::Unit::TestCase
  fixtures :publishers, :users, :roles, :roles_users, :series, :ratings, :books, :comments, :publisher_logos, :feed_sources
  
  def setup
    @controller = PublishersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_valid_markup
    login_as(:quentin)
    get :index; assert_valid_markup
    get :new; assert_valid_markup
    get :edit, :id => publishers(:marvel).to_param; assert_valid_markup
  end
  
  def test_publisher_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_select "div.book-publisher", Publisher.count
  end
  
  def test_show_publisher_titles_redirect
    get :show, :id => publishers(:marvel).to_param
    assert_response :redirect
    assert_redirected_to comic_titles_url(publishers(:marvel).to_param)
  end
  
  def test_new_publisher
    login_as(:quentin)
    get :new
    assert_response :success
    assert_template 'new'
  end
  
  def test_new_publisher_requires_login
    get :new
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_publisher_requires_login
    create_publisher
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_publisher
    login_as(:quentin)
    assert_difference Publisher, :count do
      create_publisher
      assert_response :redirect
      assert_redirected_to comic_titles_url(Publisher.find(:first, :order => "created_at DESC").to_param)
    end
  end
  
  def test_create_with_logo
    login_as(:quentin)
    assert_difference PublisherLogo, :count do
      post :create, :publisher => { :name => 'new publisher' },
           :publisher_logo => { :uploaded_data => fixture_file_upload("images/rails.png", "image/jpeg") }
      assert_response :redirect
      assert_redirected_to comic_titles_url(Publisher.find(:first, :order => "created_at DESC").to_param)
    end
  end
  
  def test_edit_publisher
    login_as(:quentin)
    get :edit, :id => publishers(:marvel).to_param
    assert_response :success
    assert_template 'edit'
  end
  
  def test_update_publisher
    # NOTE that permalink won't change!
    new_name = "new name"
    login_as(:quentin)
    put :update, :id => publishers(:marvel).to_param,
        :publisher => {:name => new_name}
    assert_response :redirect
    assert_redirected_to comic_titles_url(publishers(:marvel).to_param)
    publishers(:marvel).reload
    assert_equal new_name, publishers(:marvel).name
  end
  
  def test_update_new_logo
    login_as(:quentin)
    new_file = "comic_book_guy.png"
    put :update, :id => publishers(:marvel).to_param,
        :publisher_logo => { :uploaded_data => fixture_file_upload("images/#{new_file}", "image/jpeg") }
    assert_response :redirect
    assert_redirected_to comic_titles_url(publishers(:marvel).to_param)
    assert_equal new_file, publishers(:marvel).publisher_logo.filename
  end
  
  def test_edit_requires_login
    get :edit, :id => publishers(:marvel).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_update_requires_login
    put :update, :id => publishers(:marvel).to_param,
        :publisher => {:name => "requires login"}
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_requires_admin
    login_as(:aaron)
    create_publisher
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_new_requires_admin
    login_as(:aaron)
    get :new
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_edit_requires_admin
    login_as(:aaron)
    get :edit, :id => publishers(:marvel).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_update_requires_admin
    login_as(:aaron)
    get :update, :id => publishers(:marvel).to_param,
        :publisher => { :name => "nevermind..." }
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  protected
  
    def create_publisher(options = {})
      post :create, :publisher => { :name => 'new publisher' }.merge(options)
    end
end
