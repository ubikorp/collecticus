class RatingsController < ApplicationController
  layout nil
  
  before_filter :login_required
  before_filter :find_book
  
  # POST /comics/:comic_id/books/:book_id/ratings
  # POST /comics/:comic_id/titles/:title_id/episodes/:episode_id/ratings
  def create
    rating = params[:rating].to_i
    if rating >= 1 and rating <= 5
      Rating.delete_all(["rateable_type = 'Book' AND rateable_id = ? AND user_id = ?", 
        @book.id, current_user.id])
      @book.add_rating Rating.new(:rating => rating, 
        :user_id => current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to(@book.episode? ? comic_title_episode_path(@publisher, @title, @book) : comic_book_path(@publisher, @book)) }
      format.xml  { render(:nothing => true) }
      format.js   { render(:action => 'rate') } # render rjs
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
