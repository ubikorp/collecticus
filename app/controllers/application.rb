# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  before_filter :login_from_cookie, :init_page

  # Capture all exceptions raised when a record is not found and return a 404 (not found).
  #
  # Note that rescue_action_in_public is for requests answering false to local_request?
  # so you won't see the 404 if the request was generated locally (in development).
  #
  # Note also that the only kind of find() that raises a RecordNotFound exception is a
  # regular find by ID (as of Rails 1.1). If you're using find some other way, raise it yourself.
  def rescue_action_in_public(ex)
    if ex.is_a? ActiveRecord::RecordNotFound
      render_404
    else
      super
    end
  end

  # Render a 404 / Not Found page. Specific result determined by format (HTML, XML, etc).
  def render_404
    respond_to do |format|
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 }
      format.xml  { render :nothing => true, :status => 404 }
    end
    true
  end
  
  # Set user notices to be displayed in the layout using the flash.
  def notify(type, message)
    flash[type] = message
    logger.error("ERROR: #{message}") if type == :error
  end
  
  private
    # Set up page properties for layout
    def init_page
      @page_title = self.class.to_s.gsub(/Controller$/,'')

      @page_number = params[:page] || 1
      @page_size = App::Config.default_page_size
    end
end
