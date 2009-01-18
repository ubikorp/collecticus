require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < Test::Unit::TestCase
  fixtures :comments, :users, :books, :series, :publishers, :ratings
  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new 
  end

  #def test_valid_markup_episode_index_comments
  #  get :index, :comic_id => publishers(:dc).to_param, :title_id => series(:green_lantern).to_param, :episode_id => books(:green_lantern_21).to_param
  #  assert_valid_markup
  #end
  
  #def test_valid_markup_solobook_index_comments
  #  get :index, :comic_id => publishers(:dc).to_param, :book_id => books(:the_trials_of_shazam_vol_1).to_param
  #  assert_valid_markup
  #end
    
  #def test_valid_markup_episode_new_comment
  #  login_as(:quentin)
  #  get :new, :comic_id => publishers(:dc).to_param, :title_id => series(:green_lantern).to_param, :episode_id => books(:green_lantern_21).to_param
  #  assert_valid_markup
  #end
  
  #def test_valid_markup_solobook_new_comment
  #  login_as(:quentin)
  #  get :new, :comic_id => publishers(:dc).to_param, :book_id => books(:the_trials_of_shazam_vol_1).to_param
  #  assert_valid_markup
  #end
  
  #def test_comments_index
  #  get :index, :comic_id => publishers(:dc).to_param, :book_id => books(:the_trials_of_shazam_vol_1).to_param
  #  assert_response :success
  #  assert_template 'index'
  #  assert_select "div.comment", [books(:the_trials_of_shazam_vol_1).comments.length, 3].min
  #end
  
  def test_comments_index_redirect
    get :index, :comic_id => publishers(:dc).to_param, :book_id => books(:the_trials_of_shazam_vol_1).to_param
    assert_response :redirect
    assert_redirected_to :controller => 'books'
  end
  
  #def test_new_comment
  #  login_as(:quentin)
  #  get :new, :comic_id => publishers(:dc).to_param, :book_id => books(:the_trials_of_shazam_vol_1).to_param
  #  assert_response :success
  #  assert_template 'new'
  #  assert_select "#content", :value => /#{books(:the_trials_of_shazam_vol_1).name}/
  #end
  
  #def test_new_comment_requires_login
  #  get :new, :comic_id => publishers(:dc).to_param, :book_id => books(:the_trials_of_shazam_vol_1).to_param
  #  assert_response :redirect
  #  assert_redirected_to login_url
  #end
  
  def test_create_new_comment_requires_login
    create_comment(books(:the_trials_of_shazam_vol_1))
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_create_new_solobook_comment
    login_as(:quentin)
    create_comment(books(:the_trials_of_shazam_vol_1))
    assert_response :redirect
    assert_redirected_to comic_book_url(publishers(:dc), books(:the_trials_of_shazam_vol_1))
  end
  
  def test_create_new_episode_comment
    login_as(:quentin)
    create_comment(books(:green_lantern_21))
    assert_response :redirect
    assert_redirected_to comic_title_episode_url(publishers(:dc), series(:green_lantern), books(:green_lantern_21))
  end
  
  def test_create_validation
    login_as(:quentin)
    create_comment(books(:the_trials_of_shazam_vol_1), :body => nil)
    #assert_response :success
    #assert_template 'new'
    assert_response :redirect
    assert_redirected_to comic_book_url(publishers(:dc), books(:the_trials_of_shazam_vol_1))
    assert_not_nil flash[:error]
  end
  
  protected
  
    def create_comment(book, options = {})
      if book.episode?
        post :create, :comic_id => book.series.publisher.to_param, 
             :title_id => book.series.to_param, :episode_id => book.to_param,
             :comment => { :body => 'comment body' }.merge(options)
      else
        post :create, :comic_id => book.publisher.to_param, :book_id => book.to_param,
             :comment => { :body => 'comment body' }.merge(options)
      end
    end
end
