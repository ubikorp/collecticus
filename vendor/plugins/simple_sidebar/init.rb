require 'simple_sidebar'
ActionController::Base.send :include, SimpleSidebar
ActionController::Base.send :helper, SimpleSidebarHelper
ActionController::Base.send :sidebars_path=, "#{RAILS_ROOT}/app/views/sidebars"