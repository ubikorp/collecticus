require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  fixtures :books, :series, :publishers
  
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_valid_markup
    get :show; assert_valid_markup
  end
  
  def test_advanced_search_form
    get :show
    assert_response :success
    assert_template 'show'
  end
  
  def test_create_renders_show
    post :create
    assert_response :success
    assert_template 'show'
  end
  
  def test_search_title_default
    post :create, :query => 'amazing'
    assert_response :success
    assert_select "li.search-result", 
      Book.count(:conditions => "permalink LIKE '%amazing%'")
  end
  
  def test_search_multiple_keywords
    post :create, :query => 'amazing spider'
    assert_response :success
    assert_select "li.search-result", 
      Book.count(:conditions => "permalink LIKE '%amazing%' AND permalink LIKE '%spider%'")
  end
  
  def test_search_case_insensitive
    post :create, :query => 'AmAzInG'
    assert_response :success
    assert_select "li.search-result", 
      Book.count(:conditions => "permalink LIKE '%amazing%'")
  end
  
  def test_search_target_talent
    post :create, :query => 'writer', :target => 'talent'
    assert_response :success
    assert_select "li.search-result", 
      Book.count(:conditions => "talent LIKE '%writer%'")
  end
  
  def test_search_target_description
    post :create, :query => 'green lantern', :target => 'description'
    assert_response :success
    assert_select "li.search-result",
      Book.count(:conditions => "description LIKE '%green%' AND description LIKE '%lantern%'")
  end
  
  def test_squery_from_layout
    post :create, :squery => 'amazing'
    assert_response :success
    assert_select "li.search-result",
      Book.count(:conditions => "permalink LIKE '%amazing%'")
  end
end
