require File.dirname(__FILE__) + '/../test_helper'
require 'books_controller'

# Re-raise errors caught by the controller.
class BooksController; def rescue_action(e) raise e end; end

class BooksControllerTest < Test::Unit::TestCase
  include ActionView::Helpers::NumberHelper
  
  fixtures :series, :books, :users, :publishers, :books_users, :roles, :roles_users, :ratings, :feed_sources
  
  def setup
    @controller = BooksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_valid_markup
    login_as(:quentin)
    
    publisher_id = publishers(:marvel).to_param
    series_id = series(:amazing_spider_man).to_param
    episode_id = books(:amazing_spider_man_540).to_param
    solobook_id = books(:the_trials_of_shazam_vol_1).to_param
    
    get :index, :comic_id => publisher_id
    assert_valid_markup

    get :index, :comic_id => publisher_id, :title_id => series_id
    assert_valid_markup

    get :show, :comic_id => publisher_id, :title_id => series_id, :id => episode_id 
    assert_valid_markup
    
    get :show, :comic_id => publisher_id, :id => solobook_id
    assert_valid_markup

    get :new, :comic_id => publisher_id
    assert_valid_markup
    
    get :new, :comic_id => publisher_id, :title_id => series_id
    assert_valid_markup

    get :art, :comic_id => publisher_id, :title_id => series_id, :id => episode_id
    assert_valid_markup
    
    get :art, :comic_id => publisher_id, :id => solobook_id
    assert_valid_markup

    get :edit, :comic_id => publisher_id, :title_id => series_id, :id => episode_id
    assert_valid_markup
    
    get :edit, :comic_id => publisher_id, :id => solobook_id
    assert_valid_markup
  end
  
  def test_episode_index
    get :index, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param
    assert_response :success
    assert_template 'index'
    assert_select "tr.book-table-row", [series(:green_lantern).episodes.length, App::Config.default_page_size].min
  end  
  
  #def test_episode_index_requires_series
  #  assert_raise(ActiveRecord::RecordNotFound) do
  #    get :index, :comic_id => publishers(:dc).to_param
  #  end
  #end
  
  def test_solobook_index
    get :index, :comic_id => publishers(:dc).to_param
    assert_response :success
    assert_template 'index'
    assert_select "tr.book-table-row", publishers(:dc).solobooks.count
  end
  
  def test_show_solobook_details
    get :show, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :success
    assert_template 'show'
    assert_select "div.book-detailed", /#{books(:the_trials_of_shazam_vol_1).description}/
  end
  
  def test_show_series_episode_details
    get :show, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param, :id => books(:green_lantern_21).to_param
    assert_response :success
    assert_template 'show'
    assert_select "div.book-detailed", /#{books(:green_lantern_21).description}/
  end
  
  def test_new_episode_existing_series
    login_as(:quentin)
    get :new, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param
    assert_response :success
    assert_template 'new'
    assert_select "#page-title", :value => series(:green_lantern).name
  end
  
  def test_new_episode_no_series_specified
    login_as(:quentin)
    get :new, :comic_id => publishers(:dc).to_param
    assert_response :success
    assert_template 'new'
  end
  
  def test_new_episode_requires_login
    get :new, :comic_id => publishers(:dc).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_episode_requires_login
    create_episode
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_solobook
    login_as(:quentin)
    assert_difference SoloBook, :count do
      create_solobook
      assert_response :redirect
      assert_redirected_to :action => :show
    end
  end
  
  def test_create_new_episode
    login_as(:quentin)
    assert_difference Episode, :count do
      create_episode
      assert_response :redirect
      assert_redirected_to :action => :show
    end
  end
  
  def test_create_validation
    login_as(:quentin)
    #create_episode(:series_id => nil)
    create_episode(:number => nil)
    assert_response :success
    assert_template 'new'
    assert_not_nil flash[:error]
  end
  
  def test_create_with_cover_image
    login_as(:quentin)
    series = series(:green_lantern)
    assert_difference CoverImage, :count, 4 do
      post :create, :comic_id => publishers(:dc).to_param, 
           :title_id => series.to_param, 
           :book => { :series_id => series.id, :number => 1, 'published_on(1i)' => '2007', 'published_on(2i)' => '1', 'published_on(3i)' => '1' },
           :cover_image => { :uploaded_data => fixture_file_upload("images/rails.png", "image/jpeg") }
      assert_response :redirect
      assert_redirected_to :action => :show
    end
  end
  
  def test_art_series_episode
    get :art, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param, 
        :id => books(:green_lantern_21).to_param
    assert_response :success
    assert_template 'art'
  end
  
  def test_art_solobook
    get :art, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :success
    assert_template 'art'
  end
  
  def test_edit_episode
    login_as(:quentin)
    get :edit, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param, 
        :id => books(:green_lantern_21).to_param
    assert_response :success
    assert_template 'edit'
  end
  
  def test_edit_solobook
    login_as(:quentin)
    get :edit, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :success
    assert_template 'edit'
  end
  
  def test_update_episode
    login_as(:quentin)
    new_description = "this is an updated description"
    put :update, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param,
        :id => books(:green_lantern_21).to_param,
        :book => { :description => new_description }
    assert_response :redirect
    assert_redirected_to :action => 'show'
    books(:green_lantern_21).reload
    assert_equal new_description, books(:green_lantern_21).description
  end
  
  def test_update_solobook
    login_as(:quentin)
    new_description = "this is an updated description"
    put :update, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param,
        :book => { :description => new_description }
    assert_response :redirect
    assert_redirected_to :action => 'show'
    books(:the_trials_of_shazam_vol_1).reload
    assert_equal new_description, books(:the_trials_of_shazam_vol_1).description
  end
  
  def test_update_new_cover_image
    login_as(:quentin)
    new_file = "comic_book_guy.png"
    put :update, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param,
        :cover_image => { :uploaded_data => fixture_file_upload("images/#{new_file}", "image/jpeg") }
    assert_response :redirect
    assert_redirected_to :action => 'show'
    assert_equal new_file, books(:the_trials_of_shazam_vol_1).cover_image.filename
  end
  
  def test_edit_requires_login
    get :edit, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_update_requires_login
    put :update, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param,
        :book => { :description => "this shouldn't work!" }
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_requires_admin
    login_as(:aaron)
    create_episode
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_new_requires_admin
    login_as(:aaron)
    get :new, :comic_id => publishers(:dc).to_param,
        :title_id => series(:green_lantern).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_edit_requires_admin
    login_as(:aaron)
    get :edit, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_update_requires_admin
    login_as(:aaron)
    get :update, :comic_id => publishers(:dc).to_param, 
        :id => books(:the_trials_of_shazam_vol_1).to_param,
        :book => { :description => "nevermind..." }
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_pull_book_html_redirect
    login_as(:aaron)
    books_pulled = users(:aaron).books.length
    book_id = books(:the_trials_of_shazam_vol_1).to_param
    comic_id = publishers(:dc).to_param
    post :pull, :comic_id => comic_id, :id => book_id, :format => 'html'
    assert_response :redirect
    assert_redirected_to comic_book_url(:comic_id => comic_id, :id => book_id)
    assert_not_nil flash[:notice]
    users(:aaron).reload
    assert_equal books_pulled + 1, users(:aaron).books.length
  end
  
  def test_pull_book_xhr
    login_as(:aaron)
    books_pulled = users(:aaron).books.length
    book_id = books(:the_trials_of_shazam_vol_1).to_param
    comic_id = publishers(:dc).to_param
    xhr :post, :pull, :comic_id => comic_id, :id => book_id
    assert_response :success
    users(:aaron).reload
    assert_equal books_pulled + 1, users(:aaron).books.length
    #assert_rjs :replace, "status-#{books(:the_trials_of_shazam_vol_1).permalink}", Regexp.new("collection-status-ok")
  end
  
  def test_pull_episode_already_pulled
    login_as(:aaron)
    books_pulled = users(:aaron).books.length
    episode_id = books(:green_lantern_20).to_param
    title_id = series(:green_lantern).to_param
    comic_id = publishers(:dc).to_param
    xhr :post, :pull, :comic_id => comic_id, :title_id => title_id, :id => episode_id
    assert_response :success
    #assert_rjs :replace, "status-#{books(:green_lantern_20).permalink}", Regexp.new("collection-status-ok")
    #assert_rjs :replace, 'flash', Regexp.new("added to your collection")
    users(:aaron).reload
    assert_equal books_pulled, users(:aaron).books.length
  end
  
  def test_pull_book_requires_login
    xhr :post, :pull, :comic_id => publishers(:dc).to_param, :id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_unpull_book_html_redirect
    login_as(:aaron)
    books_pulled = users(:aaron).books.length
    episode_id = books(:green_lantern_20).to_param
    title_id = series(:green_lantern).to_param
    comic_id = publishers(:dc).to_param
    post :unpull, :comic_id => comic_id, :title_id => title_id, :id => episode_id, :format => 'html'
    assert_response :redirect
    assert_redirected_to comic_title_episode_url(:comic_id => comic_id, :title_id => title_id, :id => episode_id)
    assert_not_nil flash[:notice]
    users(:aaron).reload
    assert_equal books_pulled - 1, users(:aaron).books.length
  end
  
  def test_unpull_book_xhr
    login_as(:aaron)
    books_pulled = users(:aaron).books.length
    episode_id = books(:green_lantern_20).to_param
    title_id = series(:green_lantern).to_param
    comic_id = publishers(:dc).to_param
    xhr :post, :unpull, :comic_id => comic_id, :title_id => title_id, :id => episode_id
    assert_response :success
    users(:aaron).reload
    assert_equal books_pulled - 1, users(:aaron).books.length
  end
  
  def test_unpull_episode_not_in_list
    login_as(:aaron)
    books_pulled = users(:aaron).books.length
    book_id = books(:the_trials_of_shazam_vol_1).to_param
    comic_id = publishers(:dc).to_param
    xhr :post, :unpull, :comic_id => comic_id, :id => book_id
    assert_response :success
    users(:aaron).reload
    assert_equal books_pulled, users(:aaron).books.length
  end
  
  def test_unpull_book_requires_login
    xhr :post, :unpull, :comic_id => publishers(:dc).to_param, :title_id => series(:green_lantern).to_param, :id => books(:green_lantern_20).to_param
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_book_comments
    get :show, :comic_id => publishers(:dc).to_param, 
        :title_id => series(:green_lantern).to_param, :id => books(:green_lantern_21).to_param
    assert_response :success
    assert_select "div.comment", books(:green_lantern_21).comments.count
  end
  
  def test_average_book_rating
    get :show, :comic_id => publishers(:dc).to_param,
        :title_id => series(:green_lantern).to_param, :id => books(:green_lantern_20).to_param
    assert_response :success
    assert_select "div#star-ratings-block", :value => /"#{number_with_precision(books(:green_lantern_20).rating, 1)}\/5.0 Stars"/
  end
  
  def test_my_book_rating
    login_as(:quentin)
    get :show, :comic_id => publishers(:dc).to_param,
        :title_id => series(:green_lantern).to_param, :id => books(:green_lantern_20).to_param
    assert_response :success
    assert_select "div#star-ratings-block",
      :value => /"#{number_with_precision(books(:green_lantern_20).ratings.find(:first, 
        :conditions => "user_id = #{users(:quentin).id}").rating, 1)}\/5.0 Stars"/
  end
  
  def test_destroy_solobook
    assert_difference(Book, :count, -1) do
      login_as(:quentin)
      publisher = publishers(:dc)
      book = books(:the_trials_of_shazam_vol_1)
      delete :destroy, :comic_id => publisher.to_param, 
        :id => book.to_param
      assert_response :redirect
      assert_redirected_to :action => :index
    end
  end
  
  def test_destroy_episode
    assert_difference(Book, :count, -1) do
      login_as(:quentin)
      publisher = publishers(:dc)
      title = series(:green_lantern)
      book = books(:green_lantern_20)
      delete :destroy, :comic_id => publisher.to_param, 
        :title_id => title.to_param, 
        :id => book.to_param
      assert_response :redirect
      assert_redirected_to :action => :index
    end
  end
  
  def test_destroy_requires_admin
    assert_no_difference Book, :count do
      login_as(:aaron)
      publisher = publishers(:dc)
      title = series(:green_lantern)
      book = books(:green_lantern_20)
      delete :destroy, :comic_id => publisher.to_param, 
        :title_id => title.to_param, 
        :id => book.to_param
      assert_response :redirect
      assert_redirected_to login_url
    end
  end
  
  protected
  
    def create_episode(options = {})
      series = series(:green_lantern)
      post :create, :comic_id => series.publisher.to_param, :title_id => series.to_param, :book => { :series_id => series.id, :number => 1, 'published_on(1i)' => '2007', 'published_on(2i)' => '1', 'published_on(3i)' => '1'}.merge(options)
    end
    
    def create_solobook(options = {})
      publisher = publishers(:dc)
      post :create, :comic_id => publisher.to_param, :book => { :series_id => nil, :name => 'some new book', :publisher_id => publisher.id, 'published_on(1i)' => '2007', 'published_on(2i)' => '1', 'published_on(3i)' => '1' }.merge(options)
    end    
end
