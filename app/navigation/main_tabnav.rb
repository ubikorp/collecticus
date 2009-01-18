class MainTabnav < Tabnav::Base
  html_options :class => 'tabnav'
  
  add_tab do
    named 'New Releases'
    links_to proc { hash_for_start_path }
  end
  
  add_tab do
    named 'Browse Titles'
    links_to :controller => 'publishers', :action => 'index'
    highlights_on :controller => 'publishers'
    highlights_on :controller => 'titles'
    highlights_on :controller => 'books'
    highlights_on :controller => 'users'
  end

  add_tab do
    named 'Login'
    links_to :controller => 'session', :action => 'new'
    highlights_on :controller => 'session'
    show_if proc { !logged_in? }
  end

  add_tab do
    named 'Register'
    links_to :controller => 'account', :action => 'new'
    highlights_on :controller => 'account'
    show_if proc { !logged_in? }
  end
  
  add_tab do
    named 'Pull List'
    links_to :controller => 'account', :action => 'pulls'
    show_if proc { logged_in? }
  end

  add_tab do
    named 'My Account'
    links_to :controller => 'account', :action => 'show'
    highlights_on :controller => 'account', :action => 'edit'
    highlights_on :controller => 'account', :action => 'update'
    show_if proc { logged_in? }
  end
  
  add_tab do
    named "<a href=\"http://info.collectic.us/pages/about\">About</a>"
  end
end
