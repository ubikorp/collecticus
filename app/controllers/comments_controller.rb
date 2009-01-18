class CommentsController < ApplicationController
  before_filter :login_required, :only => [:create]
  before_filter :find_book
  
  sidebar :login, :unless => :logged_in?
  sidebar :favorite_series
  sidebar :recent_comments
  sidebar :info

  # GET /comments
  def index
    if @book.episode?
      redirect_to(comic_title_episode_path(@book.series.publisher, @book.series, @book))
    else
      redirect_to(comic_book_path(@book.publisher, @book))
    end
  end
  
  # POST /comments
  def create
    @comment = @book.comments.build({ :user => current_user }.merge(params[:comment]))
    if @comment.save
      notify(:notice, "Thanks for your comment!")
    else
      notify(:error, "Please check the form for errors.")
    end
    
    # redirect even if form has errors
    # comment model is so simply the only 'error' would be missing body text,
    # in which case we won't even bother to alert the user...
    # (if the comment form gets more complicated, we'll have to do something about this)
    if @book.episode?
      redirect_to comic_title_episode_path(@publisher, @title, @book)
    else
      redirect_to comic_book_path(@publisher, @book)
    end
  end
  
  protected

    # extract title and book details from path, set instance vars
    def find_book
      @publisher = Publisher.find_by_permalink(params[:comic_id]) || raise(ActiveRecord::RecordNotFound)
      @title = @publisher.series.find_by_permalink(params[:title_id]) if params[:title_id]
      @book = @title.nil? ? @publisher.solobooks.find_by_permalink(params[:book_id]) : @title.find_episode(params[:episode_id])
      raise(ActiveRecord::RecordNotFound) if @book.nil?
    end
end
