def __DIR__; File.dirname(__FILE__); end

RAILS_ROOT = File.join(File.dirname(__FILE__), '..')

$:.unshift(__DIR__ + '/../lib')
begin
  require 'rubygems'
rescue LoadError
  $:.unshift(__DIR__ + '/../../../rails/activerecord/lib')
  $:.unshift(__DIR__ + '/../../../rails/activesupport/lib')
  $:.unshift(__DIR__ + '/../../../rails/actionpack/lib')
end
require 'test/unit'
require 'active_support'

# for controller test
require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'

# ActionController::Base.ignore_missing_templates = true
# ActionController::Routing::Routes.reload rescue nil
class ActionController::Base; def rescue_action(e) raise e end; end

class Test::Unit::TestCase
  
  # http://project.ioni.st/post/217#post-217
  #
  #  def test_new_publication
  #    assert_difference(Publication, :count) do
  #      post :create, :publication => {...}
  #      # ...
  #    end
  #  end
  #
  # modified by mabs29 to include arguments
  def assert_difference(object, method = nil, difference = 1, *args)
    initial_value = object.send(method, *args)
    yield
    assert_equal initial_value + difference, object.send(method, *args), "#{object}##{method}"
  end

  def assert_no_difference(object, method, *args, &block)
    assert_difference object, method, 0, *args, &block
  end

end

# load up SimpleSidebar
require File.join(File.dirname(__FILE__), '..', 'init')

ActionController::Base.send :sidebars_path=, "#{File.dirname(__FILE__)}/sidebars"

class TestController < ActionController::Base
  def index
  end
end