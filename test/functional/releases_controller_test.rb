require File.dirname(__FILE__) + '/../test_helper'
require 'releases_controller'

# Re-raise errors caught by the controller.
class ReleasesController; def rescue_action(e) raise e end; end

class ReleasesControllerTest < Test::Unit::TestCase
  fixtures :series, :books, :comments, :ratings, :feed_sources
  
  def setup
    @controller = ReleasesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_valid_markup
    get :show; assert_valid_markup
  end
  
  def test_current_releases
    get :show
    assert_response :success
    assert_template 'show'
  end
  
  def test_current_release_count
    current_releases = Book.find(:all, 
                         :conditions => ["published_on > ? AND published_on < ?",
                           Time.now.beginning_of_week, Time.now.beginning_of_week + 7.days])
    get :show
    assert_select "div.featured-books > div.book-featured", [current_releases.length, App::Config.featured_books_size].min
    assert_select "div.current-books > div.book-current", [current_releases.length - App::Config.featured_books_size, 0].max
  end
  
  def test_next_week_release_count
    date = Time.now + 7.days
    next_week_releases = Book.find(:all,
                           :conditions => ["published_on > ? AND published_on < ?",
                             Time.now.beginning_of_week + 7.days, Time.now.beginning_of_week + 14.days])
    get :show, :year => date.strftime("%Y"), :month => date.strftime("%m"), :day => date.strftime("%d")
    assert_select "div#page-title", /#{date.strftime("%B %d, %Y")}/
    assert_select "div.featured-books > div.book-featured", [next_week_releases.length, App::Config.featured_books_size].min
    assert_select "div.current-books > tr.book-table-row", [next_week_releases.length - App::Config.featured_books_size, 0].max
  end
  
  def test_ordered_by_popularity
    date = Time.now.beginning_of_week
    books = Book.find(:all, :select => "books.*, COUNT(books.id) AS pulls",
                      :joins => "INNER JOIN books_users ON books.id = books_users.book_id",
                      :group => "books_users.book_id",
                      :order => "pulls DESC, permalink ASC",
                      :limit => App::Config.featured_books_size,
                      :conditions => ["published_on > ? AND published_on < ?",
                        date, date + 7.days])
              
    not_included = books.collect { |book| "AND id != #{book.id}" }.join(' ')
    books = books.concat(Book.find(:all, :order => "permalink ASC",
               :conditions => ["published_on > ? AND published_on < ? #{not_included}", 
                 date, date + 7.days]))
    
    get :show
    assert_select "div.featured-books > div.book-featured", [books.length, App::Config.featured_books_size].min
    assert_select "div.featured-books > div.book-featured:first-child", /#{books[0].name}/
  end
end
