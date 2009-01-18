# This controller provides lists of comic book releases by date.
class ReleasesController < ApplicationController
  helper 'books', 'comments'
  before_filter :set_date
  
  sidebar :login, :unless => :logged_in?
  sidebar :releases
  sidebar :favorite_series
  sidebar :recent_comments
  sidebar :info
  sidebar :news

  def show
    @date ||= Time.now.beginning_of_week + 2.days
    @date += 12.hours # for DST shift
    @page_title = "Releases for #{@date.strftime('%A, %B %d, %Y')}"

    @books = Book.find(:all, :select => "books.*, COUNT(books.id) AS pulls",
                       :joins => "INNER JOIN books_users ON books.id = books_users.book_id",
                       :group => "books_users.book_id",
                       :order => "pulls DESC, permalink ASC",
                       :limit => App::Config.featured_books_size,
                       :conditions => ["published_on > ? AND published_on < ?",
                         @date.beginning_of_week, @date.beginning_of_week + 7.days])
             
    not_included = @books.collect { |book| "AND id != #{book.id}" }.join(' ')
    @books = @books.concat(Book.find(:all, :order => "permalink ASC",
               :conditions => ["published_on > ? AND published_on < ? #{not_included}", 
                 @date.beginning_of_week, @date.beginning_of_week + 7.days]))
  end
  
  protected
  
    # set the date from parameters
    def set_date
      unless params[:year].nil?
        date_string = "#{params[:year]}-#{params[:month]}-#{params[:day]}"
        @date = Time.parse(date_string)
      end
    end
end
