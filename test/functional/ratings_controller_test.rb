require File.dirname(__FILE__) + '/../test_helper'
require 'ratings_controller'

# Re-raise errors caught by the controller.
class RatingsController; def rescue_action(e) raise e end; end

class RatingsControllerTest < Test::Unit::TestCase
  include ActionView::Helpers::NumberHelper
  fixtures :ratings, :books, :series, :publishers, :users, :comments
  
  def setup
    @controller = RatingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_create_requires_login
    post :create, :comic_id => publishers(:dc).to_param,
         :title_id => series(:green_lantern).to_param,
         :episode_id => books(:green_lantern_21).to_param,
         :rating => 1
    assert_response :redirect
    assert_redirected_to login_url
  end

  def test_create_rating_rjs_solobook
    login_as(:quentin)
    assert_difference Rating, :count do
      xhr :post, :create, :comic_id => publishers(:dc).to_param,
                 :book_id => books(:the_trials_of_shazam_vol_1).to_param,
                 :rating => 3
      assert_response :success
      assert_rjs :replace_html, 'star-ratings-block', Regexp.new("3.0/5.0 Stars")
    end
  end
  
  def test_create_rating_rjs_episode
    login_as(:quentin)
    assert_difference Rating, :count do
      xhr :post, :create, :comic_id => publishers(:dc).to_param,
                 :title_id => series(:green_lantern).to_param,
                 :episode_id => books(:green_lantern_21).to_param,
                 :rating => 1
      assert_response :success
      assert_rjs :replace_html, 'star-ratings-block', Regexp.new("1.0/5.0 Stars")
    end
  end
  
  def test_create_rating_average_updated
    login_as(:quentin)
    episode = books(:green_lantern_21)
    average_rating = episode.rating
    number_of_votes = episode.ratings.length
    my_rating = 1
    xhr :post, :create, :comic_id => episode.series.publisher.to_param,
               :title_id => episode.series.to_param,
               :episode_id => episode.to_param, :rating => my_rating
    episode.reload
    assert_equal episode.rating, (average_rating * number_of_votes + my_rating) / episode.ratings.length
  end
  
  def test_create_rating_html
    login_as(:quentin)
    assert_difference Rating, :count do
      comic_id = publishers(:dc).to_param
      title_id = series(:green_lantern).to_param
      episode_id = books(:green_lantern_21).to_param
    
      post :create, :comic_id => comic_id, :title_id => title_id, 
           :episode_id => episode_id, :rating => 1
      assert_response :redirect
      assert_redirected_to comic_title_episode_url(comic_id, title_id, episode_id)
    end
  end
  
  def test_invalid_rating
    login_as(:quentin)
    episode = books(:green_lantern_21)
    previous_average = episode.rating
    my_rating = 10000 # must be between 1 and 5
    assert_no_difference Rating, :count do
      xhr :post, :create, :comic_id => episode.series.publisher.to_param,
          :title_id => episode.series.to_param,
          :episode_id => episode.to_param, :rating => my_rating
      assert_response :success
      assert_rjs :replace_html, 'star-ratings-block', Regexp.new("#{number_with_precision(previous_average, 1)}/5.0 Stars")
    end
  end
  
  def test_rate_twice
    login_as(:aaron) # already rated this episode
    episode = books(:green_lantern_21)
    previous_average = episode.rating
    assert_no_difference Rating, :count do
      xhr :post, :create, :comic_id => episode.series.publisher.to_param,
                 :title_id => episode.series.to_param,
                 :episode_id => episode.to_param, :rating => 1
      assert_response :success
      assert_rjs :replace_html, 'star-ratings-block', Regexp.new("1.0/5.0 Stars")
      episode.reload
      assert_not_equal previous_average, episode.rating
    end
  end
end
