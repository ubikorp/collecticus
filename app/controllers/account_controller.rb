# This controller handles user account functions. Examples include creation
# of new user accounts and managing user preferences.
class AccountController < ApplicationController
  helper 'books'
  
  before_filter :login_required, :except => [:new, :create]
  
  sidebar :favorite_series
  sidebar :recent_comments
  
  # show account preferences
  # GET /account
  def show
    @page_title = "My Account Preferences"
  end
  
  # show my present and future pull list
  # if params[:prev] is set, show previous pulls instead
  # GET /accounts;pulls
  def pulls
    @page_title = "My Pull List"
    comic_book_day = Time.now.beginning_of_week + 2.days # Wednesday
    
    @prev = params[:prev]
    if @prev
      @page_title += " (Previous Pulls)"
      comic_book_day -= 1.week
    end
    
    @release_dates = []
    @releases = []
    0.upto(9) do |i|      
      @releases << current_user.books.by_week(comic_book_day)
      @release_dates << comic_book_day
      
      if @prev
        comic_book_day -= 1.week
      else
        comic_book_day += 1.week
      end
    end
  end

  # render new user registration form
  # GET /account/new
  def new
    @page_title = "Register"
  end

  # create the user account
  # POST /account
  def create
    @page_title = "Register"
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    notify(:notice, "Thanks for signing up!")
  rescue ActiveRecord::RecordInvalid
    render(:action => 'new')
  end
  
  def edit
    @page_title = "Edit Account Preferences"
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      notify(:notice, "Your account preferences were updated.")
      redirect_to(:action => 'show')
    else
      render(:action => 'edit')
    end
  end
end
