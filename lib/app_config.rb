require 'active_support'

# Central application config (consolidate those constants!)
module App
   module Config
    mattr_accessor :app_name
    mattr_accessor :app_name_slug
    
    mattr_accessor :web_host
    
    mattr_accessor :default_image_path_sm
    mattr_accessor :default_image_path_md
    mattr_accessor :default_image_path_lg
    
    mattr_accessor :default_page_size
    mattr_accessor :featured_books_size
    
    mattr_accessor :sidebar_info_size
    mattr_accessor :sidebar_news_size
    
    # ==========
    
    @@app_name = "collectic.us"
    @@app_name_slug = "collecticus"
    
    @@web_host = "collectic.us"
    
    @@default_image_path_sm = "art/default_40x60.jpg"
    @@default_image_path_md = "art/default_80x120.jpg"
    @@default_image_path_lg = "art/default_120x180.jpg"
    
    @@default_page_size = 25
    @@featured_books_size = 4
    
    @@sidebar_info_size = 5
    @@sidebar_news_size = 15
  end
end

