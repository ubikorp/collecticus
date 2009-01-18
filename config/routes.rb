ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  map.resource  :search, :session
  map.resource  :account, :member => {:pulls => :get}
  map.resources :users
  
  map.resources :comics, :controller => 'publishers' do |publisher|
    publisher.resources :books, :member => {:art => :get, :pull => :post, :unpull => :post} do |book|
      book.resources :comments, :name_prefix => "book_"
      book.resources :ratings, :name_prefix => "book_"
    end
    publisher.resources :titles do |title|
      title.resources :episodes, :controller => 'books', :member => {:art => :get, :pull => :post, :unpull => :post} do |episode|
        episode.resources :comments, :name_prefix => "episode_"
        episode.resources :ratings, :name_prefix => "episode_"
      end
    end
  end

  map.releases 'releases/:year/:month/:day',
               :controller => 'releases', :action => 'show',
               :year => nil, :month => nil, :day => nil,
               :requirements => {:year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }
  
  map.start '/', :controller => 'releases', :action => 'show'
  map.login '/login/:return', :controller => 'session', :action => 'new', :return => false
  map.logout '/logout', :controller => 'session', :action => 'destroy'
  
  #map.comatose_admin 'admin'
  #map.comatose_root 'pages', :layout => 'application'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
