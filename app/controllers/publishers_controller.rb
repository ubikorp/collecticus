class PublishersController < ApplicationController
  before_filter :login_required, :only => [:new, :edit, :create, :update]
  before_filter :find_publisher, :only => [:show, :edit, :update]
  
  sidebar :login, :unless => :logged_in?
  sidebar :favorite_series
  sidebar :recent_comments
  sidebar :info
  
  # GET /comics
  def index
    @page_title = "Comic Publishers"
    @publishers = Publisher.find(:all, :order => "name")
  end

  # GET /comics/:id
  def show
    redirect_to(comic_titles_path(@publisher))
  end

  # GET /comics/new
  def new
    permit "admin" do
      @page_title = "New Publisher"
    end
  end
  
  # POST /comics
  def create
    has_image = false
    permit "admin" do
      @publisher = Publisher.new(params[:publisher])
      has_image = params[:publisher_logo] && !params[:publisher_logo][:uploaded_data].blank?
      @publisher_logo = @publisher.build_publisher_logo(params[:publisher_logo]) if has_image
      
      Publisher.transaction do
        @publisher.save!
        @publisher_logo.save! if has_image
        
        notify(:notice, "The publisher has been added.")
        show
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @publisher_logo.valid? if has_image # force validation
    notify(:error, "Please check the form for errors.")
    render(:action => 'new')
  end

  # GET /comics/:id/edit
  def edit
    permit "admin" do
      @page_title = "Edit Publisher Information"
    end
  end
  
  # PUT /comics/:id
  def update
    has_image = false
    permit "admin" do
      has_image = params[:publisher_logo] && !params[:publisher_logo][:uploaded_data].blank?
      @publisher_logo = @publisher.publisher_logo || @publisher.build_publisher_logo
      
      Publisher.transaction do
        @publisher.update_attributes!(params[:publisher])
        @publisher_logo.update_attributes!(params[:publisher_logo]) if has_image
        
        notify(:notice, "Publisher was successfully updated.")
        show
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @publisher_logo.valid? if has_image
    notify(:error, "Please check the form for errors.")
    render(:action => 'edit')
  end   
  
  protected
  
    # find the publisher given in the params (or raise)
    def find_publisher
      @publisher = Publisher.find_by_permalink(params[:id]) || raise(ActiveRecord::RecordNotFound)
    end
end
