# This controller handles display of user profiles within the system.
class UsersController < ApplicationController
  
  sidebar :login, :unless => :logged_in?
  sidebar :favorite_series
  sidebar :recent_comments
  sidebar :info
  
  # show the user profile
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_login(params[:id]) || raise(ActiveRecord::RecordNotFound)
    @page_title = "User Profile for #{@user.login}"
    respond_to do |format|
      format.html
      format.xml  { @user.to_xml }
    end
  end
end
