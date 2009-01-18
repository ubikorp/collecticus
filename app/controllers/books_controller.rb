# This controller handles browsing and creating books (solobooks, episodes)
# Can be nested under a series controller as well for episodes
class BooksController < ApplicationController
  helper 'comments', 'ratings'
  before_filter :login_required, :only => [:new, :create, :edit, :update, :pull, :unpull, :destroy]
  before_filter :find_title
  
  sidebar :login, :unless => :logged_in?
  sidebar :favorite_series
  sidebar :recent_comments
  sidebar :info
  
  # GET /comics/:comic_id/titles/:title_id/episodes
  def index
    if @title.nil?
      #raise(ActiveRecord::RecordNotFound)
      # show all books not belonging to a series if title is not specified
      @page_title = "Trades, Specials, and One-Shots"
      @books = @publisher.solobooks.paginate(@page_number, @page_size)
    else
      @page_title = "#{@title.name} Episode List"
      @books = @title.episodes.paginate(@page_number, @page_size)
    end
  end

  # GET /comics/:comic_id/books/:id
  # GET /comics/:comic_id/titles/:title_id/episodes/:id
  def show
    @book = @title.nil? ? find_book(params[:id]) : find_episode(@title, params[:id])
    @page_title = "Details for #{@book.name}"
  end

  # GET /comics/:comic_id/books/new
  # GET /comics/:comic_id/titles/:title_id/episodes/new
  def new
    permit "admin" do
      @page_title = "New Book"
      if @title.nil?
        @book = SoloBook.new(:publisher => @publisher)
        @publisher_list = Publisher.find(:all)
      else
        @book = Episode.new(:publisher => @publisher, :series => @title)
      end
    end
  end
  
  # POST /comics/:comic_id/books
  # POST /comics/:comic_id/titles/:title_id/episodes
  def create
    has_image = false
    permit "admin" do
      if @title.nil?
        @book = SoloBook.new(params[:book].merge({:publisher => @publisher}))
      else
        @book = @title.episodes.build(params[:book])
      end

      has_image = params[:cover_image] && !params[:cover_image][:uploaded_data].blank?
      @cover_image = @book.build_cover_image(params[:cover_image]) if has_image

      Episode.transaction do
        @book.save!
        @cover_image.save! if has_image
      
        notify(:notice, "The book has been added.")
        redirect_to(@book.episode? ? comic_title_episode_path(@publisher, @title, @book) : comic_book_path(@publisher, @book))
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @cover_image.valid? if has_image # force validation
    notify(:error, "Please check the form for errors.")
    
    @publisher_list = Publisher.find(:all) if @title.nil?
    render(:action => :new)
  end
  
  # GET /comics/:comic_id/books/:id/edit
  # GET /comics/:comic_id/titles/:title_id/episodes/:id/edit
  def edit
    permit "admin" do
      if @title.nil?
        @book = find_book(params[:id])
        @publisher_list = Publisher.find(:all)
      else
        @book = find_episode(@title, params[:id])
      end
      @page_title = "Edit Book Details"
    end
  end
  
  # PUT /comics/:comic_id/books/:id
  # PUT /comics/:comic_id/titles/:title_id/episodes/:id
  def update
    has_image = false
    permit "admin" do
      @book = @title.nil? ? find_book(params[:id]) : find_episode(@title, params[:id])
    
      has_image = params[:cover_image] && !params[:cover_image][:uploaded_data].blank?
      @cover_image = @book.cover_image || @book.build_cover_image
        
      Episode.transaction do
        @book.update_attributes!(params[:book])
        @cover_image.update_attributes!(params[:cover_image]) if has_image
      
        notify(:notice, "Book was successfully updated.")
        redirect_to(@title.nil? ? comic_book_path(@publisher, @book) : comic_title_episode_path(@publisher, @title, @book))
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @cover_image.valid? if has_image
    notify(:error, "Please check the form for errors.")
    
    @publisher_list = Publisher.find(:all) if @title.nil?
    render(:action => 'edit')
  end
  
  # GET /comics/:comic_id/books/:id/art
  # GET /comics/:comic_id/titles/:title_id/episodes/:id/art
  # display full-size cover image for the selected book/episode
  def art
    show
    render(:layout => 'popup')
  end
  
  # POST /comics/:comic_id/books/:id;pull
  # POST /comics/:comic_id/titles/:title_id/episodes/:id;pull
  # add the book to my collection
  def pull
    @book = @title.nil? ? find_book(params[:id]) : find_episode(@title, params[:id])
    if current_user.books.find(:first, :conditions => ["permalink = ?", @book.permalink]).nil?
      current_user.books << @book
    end
    
    respond_to do |format|
      format.xml  { render(:nothing => true) }
      format.html do
        notify(:notice, "The book was added to your pull list.")
        redirect_to(@book.episode? ? comic_title_episode_path(@publisher, @title, @book) : comic_book_path(@publisher, @book))
      end
      format.js do
        render(:text => '', :status => 200)
        #render(:update) do |page|
        #  page.replace("status-#{@book.permalink}", "<div id=\"status-#{@book.permalink}>\" class=\"collection-status-ok\">&#10003; Pulled</div>")          
        #end
      end
    end
  end
  
  # POST /comics/:comic_id/books/:id;unpull
  # POST /comics/:comic_id/titles/:title_id/episodes/:id;unpull
  # remove the book from my collection (heh, stupid name I know.. but push didn't seem right)
  def unpull
    @book = @title.nil? ? find_book(params[:id]) : find_episode(@title, params[:id])
    unless current_user.books.find(:first, :conditions => ["permalink = ?", @book.permalink]).nil?
      current_user.books.delete(@book)
    end
    
    respond_to do |format|
      format.xml { render(:nothing => true) }
      format.html do
        notify(:notice, "The book was removed from your pull list.")
        redirect_to(@book.episode? ? comic_title_episode_path(@publisher, @title, @book) : comic_book_path(@publisher, @book))
      end
      format.js { render(:text => '', :status => 200) }
    end
  end
  
  # DELETE /comics/:comic_id/:id
  # DELETE /comics/:comic_id/titles/:title_id/episodes/:id
  def destroy
    permit "admin" do
      @book = @title.nil? ? find_book(params[:id]) : find_episode(@title, params[:id])
      @book.destroy
      
      notify(:notice, "The book has been deleted.")
      redirect_to(@book.episode? ? comic_title_episodes_path(@publisher, @title) : comic_books_path(@publisher))
    end
  end
  
  protected
  
    # extract series details from path, set instance var
    def find_title
      @publisher = Publisher.find_by_permalink(params[:comic_id]) || raise(ActiveRecord::RecordNotFound)
      @title = params[:title_id] ? @publisher.series.find_by_permalink(params[:title_id]) : nil
    end
    
    # return the Episode corresponding to the specified Series and episode number (or raise)
    def find_episode(title, number)
      @book = title.find_episode(number) || raise(ActiveRecord::RecordNotFound)
    end
    
    # return the book corresponding to the specified permalink (or raise)
    def find_book(permalink)
      @book = Book.find_by_permalink(permalink) || raise(ActiveRecord::RecordNotFound)
    end
end
