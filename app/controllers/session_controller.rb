# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController

  sidebar :favorite_series
  sidebar :recent_comments
  
  # render login form
  # GET /session/new
  def new
    @page_title = "Login"
    check_referer if params[:return]
  end

  # process login request
  # POST /session
  def create
    @page_title = "Login"
    check_referer
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "Incorrect. Please try again."
      render :action => 'new'
    end
  end

  # logout
  # DELETE /session
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  protected
  
    # if logging in from the sidebar, save the referer so we can redirect back afterwards
    def check_referer
      referer = request.env['HTTP_REFERER'] || ""
      if (referer.match(start_url) || referer.match('blog.collectic.us')) && !referer.match(session_url) && !referer.match(login_url)
        store_location(request.env['HTTP_REFERER'])
      end
    end
end
