require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :books, :series, :ratings, :comments, :feed_sources

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_valid_markup
    #get :index; assert_valid_markup
    get :show, :id => users(:quentin).to_param; assert_valid_markup
  end
  
  def test_show_user_profile
    get :show, :id => users(:quentin).to_param
    assert_response :success
    assert_template 'show'
  end
end
