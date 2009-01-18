# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Make a notify method available so we can send the page object a message, ex:
  #   page.notify(:notice, "that thing you wanted to happen worked!")
  def notify(type, message)
    type = type.to_s # convert symbol to string
    page.replace 'flash', "<div id='flash' class='alert #{type}'>#{message}</h4>"
    #page.visual_effect :fade, 'flash', :duration => 8.0 # fade message; requires scriptaculous
  end
  
  # Display windowed pagination links (pagination helper)
  # Big thnx to: http://www.igvita.com/blog/2006/09/10/faster-pagination-in-rails/
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    current_page = pagingEnum.page
    html = ''

    #Calculate the window start and end pages
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

    # Print window pages
    first.upto(last) do |page|
      (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end

    # Print end page if anchors are enabled
    html << yield(pagingEnum.last_page) if always_show_anchors and not last == pagingEnum.last_page
    html
  end
  
  # Generate URL for previous release date
  def prev_release_path(date)
    prev_date = date - 7.days
    release_date_path(prev_date)
  end
  
  # Generate URL for next release date
  def next_release_path(date)
    next_date = date + 7.days
    release_date_path(next_date)
  end
  
  # Generate URL for browsing this release date
  def release_date_path(date)
    year = date.strftime("%Y")
    month = date.strftime("%m")
    day = date.strftime("%d")
    url_for(:controller => 'releases', :action => 'show', :year => year, :month => month, :day => day)
  end
  
  # Generate URL for browsing books (episode vs tpb/solobook)
  def comicbook_path(book, options = {})
    if book.episode?
      url_for({ :controller => 'books',
                :action => 'show',
                :comic_id => book.series.publisher,
                :title_id => book.series,
                :id => book }.merge(options))
    else
      url_for({ :controller => 'books',
                :action => 'show',
                :comic_id => book.publisher,
                :id => book }.merge(options))
    end
  end
  
  # Helper method determines whether or not the current user is an administrator
  def user_admin?
    return false unless logged_in?
    current_user.has_role?('admin')
  end
  
  # Returns the title of the page
  def page_title
    @page_title || (@page.nil? ? nil : @page.title)
  end

  # Render the basic breadcrumb trail
  def breadcrumb
    crumbs = [ link_to('Home', start_path) ]
    
    if @publisher or @controller.controller_name == "publishers"
      crumbs << link_to('Comics', comics_path)
      if @publisher
        crumbs << link_to(@publisher.name, comic_titles_path(@publisher)) if !@publisher.new_record?
        crumbs << link_to(@title.name, comic_title_episodes_path(@publisher, @title)) if @title and !@title.new_record?
        crumbs << link_to(@book.name, comic_book_path(@publisher, @book)) if @book and !@book.episode? and !@book.new_record?
        crumbs << link_to(@book.number, comic_title_episode_path(@publisher, @title, @book)) if @book and @book.episode? and !@book.new_record?
      end
    end
    
    if @controller.controller_name == 'releases'
      display_date = params[:year] ? "#{params[:year]}-#{params[:month]}-#{params[:day]}" : "Current"
      crumbs << link_to('Releases', start_path)
      crumbs << link_to(display_date, releases_path(:year => params[:year], :month => params[:month], :day => params[:day]))
    end
    
    if @controller.controller_name == 'account'
      if @controller.action_name == 'new' || @controller.action_name == 'create'
        crumbs << link_to('Register', new_account_path)
      else
        crumbs << link_to('Account Preferences', account_path)
      end
    end
    
    crumbs << link_to("User Profile for #{@user.login}", user_path(@user)) if @controller.controller_name == "users"
    crumbs << link_to('Search', search_path) if @controller.controller_name == "search"
    #crumbs << link_to(@page.title, comatose_path(@page.slug)) if @controller.controller_name == "comatose"
    crumbs << link_to('Login', login_path) if @controller.controller_name == "session"
    crumbs.join(' &raquo; ')
  end
    
  # Returns the path to a given index (user-visible page) in the Comatose CMS
  def comatose_path(page, options = {})
    url_for({ :layout=>"application", 
              :root=>"/pages", 
              :index=>"", 
              :page=>[page], 
              :controller=>"comatose", 
              :cache_path=>nil, 
              :action=>"show", 
              :use_cache=>"true" }.merge(options))
  end
end
