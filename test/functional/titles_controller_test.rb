require File.dirname(__FILE__) + '/../test_helper'
require 'titles_controller'

# Re-raise errors caught by the controller.
class TitlesController; def rescue_action(e) raise e end; end

class TitlesControllerTest < Test::Unit::TestCase
  fixtures :series, :books, :publishers, :users, :roles, :roles_users, :comments, :ratings, :feed_sources
  
  def setup
    @controller = TitlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_valid_markup
    login_as(:quentin)
    get :index, :comic_id => publishers(:dc).to_param; assert_valid_markup
    #get :show, :id => series(:green_lantern).to_param; assert_valid_markup
    get :new, :comic_id => publishers(:dc).to_param; assert_valid_markup
    get :edit, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param; assert_valid_markup
  end
  
  def test_titles_index
    get :index, :comic_id => publishers(:dc).to_param
    assert_response :success
    assert_template 'index'
    assert_select "div.book-series", [publishers(:dc).series.count + 1, App::Config.default_page_size + 1].min
    # +1 for 'specials / one-shots / tpbs' listing
  end
  
  #def test_show_series_details_and_episode_list
  #  get :show, :id => series(:green_lantern).to_param
  #  assert_response :success
  #  assert_template 'show'
  #end
  
  def test_show_series_detail_redirect
    get :show, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param
    assert_response :redirect
    assert_redirected_to comic_title_episodes_url(publishers(:dc).to_param, series(:green_lantern).to_param)
  end
  
  def test_new_episode
    login_as(:quentin)
    get :new, :comic_id => publishers(:dc).to_param
    assert_response :success
    assert_template 'new'
    assert_select "#page-data", :value => /#{publishers(:dc).name}/
  end
  
  def test_new_episode_requires_login
    get :new, :comic_id => publishers(:dc).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_series_requires_login
    create_series
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_series
    login_as(:quentin)
    create_series
    assert_response :redirect
    assert_redirected_to comic_title_episodes_url(publishers(:dc).to_param, 
      publishers(:dc).series.find(:first, :order => "created_at DESC").permalink)
  end
  
  def test_create_validation
    login_as(:quentin)
    create_series(:name => nil)
    assert_response :success
    assert_template 'new'
    assert_not_nil flash[:error]
  end
  
  def test_edit_series
    login_as(:quentin)
    get :edit, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param
    assert_response :success
    assert_template 'edit'
    assert_select "#page-data", :value => /#{series(:green_lantern).name}/
  end
  
  def test_update_series
    # NOTE that permalink won't change!
    new_name = "new name"
    login_as(:quentin)
    put :update, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param,
        :series => {:name => new_name}
    assert_response :redirect
    assert_redirected_to comic_title_episodes_url(series(:green_lantern).publisher.to_param, series(:green_lantern).to_param)
    series(:green_lantern).reload
    assert_equal new_name, series(:green_lantern).name
  end
  
  def test_edit_requires_login
    get :edit, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_update_requires_login
    put :update, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param,
        :series => {:name => "requires login"}
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_requires_admin
    login_as(:aaron)
    create_series
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_new_requires_admin
    login_as(:aaron)
    get :new, :comic_id => publishers(:dc).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_edit_requires_admin
    login_as(:aaron)
    get :edit, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_update_requires_admin
    login_as(:aaron)
    get :update, :comic_id => publishers(:dc).to_param, :id => series(:green_lantern).to_param,
        :series => { :name => "nevermind..." }
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_destroy_series
    assert_difference(Series, :count, -1) do
      login_as(:quentin)
      delete :destroy, :comic_id => publishers(:dc).to_param, 
        :id => series(:green_lantern).to_param
      assert_response :redirect
      assert_redirected_to :action => :index
    end
  end
  
  def test_destroy_series_destroys_children
    series = series(:green_lantern)
    episode_count = series.episodes.size
    assert_difference(Book, :count, -episode_count) do
      login_as(:quentin)
      delete :destroy, :comic_id => series.publisher.to_param,
        :id => series.to_param
    end
  end
  
  def test_destroy_requires_admin
    assert_no_difference(Series, :count) do
      login_as(:aaron)
      delete :destroy, :comic_id => publishers(:dc).to_param,
        :id => series(:green_lantern).to_param
      assert_response :redirect
      assert_redirected_to login_url
    end
  end
  
  protected
  
    def create_series(options = {})
      post :create, :comic_id => publishers(:dc).to_param, 
           :series => { :publisher_id => publishers(:dc), :name => 'new series' }.merge(options)
    end
end
