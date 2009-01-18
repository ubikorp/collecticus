# This controller manages series of books.
class TitlesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_publisher
  
  sidebar :login, :unless => :logged_in?
  sidebar :favorite_series
  sidebar :recent_comments
  sidebar :info
  
  helper 'books'
  
  # GET /comics/:comic_id/titles
  def index
    @titles = @publisher.series.paginate(@page_number, @page_size)
    @page_title = "Titles Published by #{@publisher.name}"
  end

  # GET /comics/:comic_id/titles/:id
  def show
    redirect_to(comic_title_episodes_path(@publisher, params[:id]))
  end

  # GET /comics/:comic_id/titles/new
  def new
    permit "admin" do
      @page_title = "New Title"
      @title = @publisher.series.build
    end
  end

  # POST /comics/:comid_id/titles
  def create
    permit "admin" do
      @title = @publisher.series.build(params[:series])
      if @title.save
        notify(:notice, "The title has been added.")
        redirect_to(comic_title_episodes_path(@publisher, @title))
      else
        notify(:error, "Please check the form for errors.")
        render(:action => :new)
      end
    end
  end
  
  # GET /comics/:comic_id/titles/:id/edit
  def edit
    permit "admin" do
      @page_title = "Edit Title Information"
    end
  end
  
  # PUT /series/:id
  def update
    permit "admin" do
      if @title.update_attributes(params[:series])
        notify(:notice, "Title was successfully updated.")
        show
      else
        notify(:error, "Please check the form for errors.")
        render(:action => 'edit')
      end
    end
  end
  
  # DELETE /series/:id
  def destroy
    permit "admin" do
      @title.destroy
      
      notify(:notice, "The series has been deleted.")
      redirect_to(comic_titles_path(@publisher))
    end
  end
  
  protected
  
    def find_publisher
      @publisher = Publisher.find_by_permalink(params[:comic_id]) || raise(ActiveRecord::RecordNotFound)
      @title = Series.find_by_permalink(params[:id]) || raise(ActiveRecord::RecordNotFound) if params[:id]
    end
end
