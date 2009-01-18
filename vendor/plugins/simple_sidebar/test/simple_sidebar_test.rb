require "#{File.dirname(__FILE__)}/test_helper"

class SimpleSidebarTest < Test::Unit::TestCase

  def setup
    @controller = ActionController::Base.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @c_class = @controller.class
    @c_class.sidebar_clear
  end
  
  def test_should_not_accept_empty_definitions
    assert_raise(SimpleSidebar::UnknownSidebarIdentifier) do
      @c_class.sidebar nil
    end
  end
  
  def test_should_raise_exception_for_unknown_partials
    assert_raise(SimpleSidebar::UnknownSidebarPartial) do
      @c_class.sidebar :bogus
    end
  end

=begin
  def test_should_raise_exception_for_unknown_method_condition
    assert_raise(SimpleSidebar::UnknownSidebarCondition) do
      @c_class.sidebar :index, :if => :gibberish!
    end
  end
=end
  
  def test_should_append_new_sidebars
    assert_difference @c_class.sidebars, :length, 2 do
      @c_class.sidebar :index
      @c_class.sidebar :next
    end
  end
  
  def test_should_symbolise_action_conditionals
    @c_class.sidebar :index, :only => "rescue_action", :except => "rescue_action_in_public"
    last_sidebar = @c_class.sidebars.last
    assert_equal :index, last_sidebar[:id]
    assert_equal [:rescue_action], last_sidebar[:only]
    assert_equal [:rescue_action_in_public], last_sidebar[:except]
  end
  
  def test_should_not_append_sidebar_if_it_exists
    assert_difference @c_class.sidebars, :length, 1 do
      @c_class.sidebar :index
      @c_class.sidebar :index, :if => :logged_in?
      @c_class.sidebar :index, :unless => :logged_in?
      @c_class.sidebar :index, :except => :something
    end
    assert_equal [{:id => :index, :priority => 1}], @c_class.sidebars
  end
  
  def test_should_delete_sidebars
    assert_no_difference @c_class.sidebars, :length do
      @c_class.sidebar :index
      @c_class.sidebar_delete :index
    end
  end
  
  def test_should_move_sidebars
    standard_sidebars
    assert_equal :index, @c_class.sidebars.first[:id]
    @c_class.sidebar_move :next, :up
    assert_equal :next, @c_class.sidebars.first[:id]
    @c_class.sidebar_move :index, :bottom
    assert_equal :index, @c_class.sidebars.last[:id]
    @c_class.sidebar_move :last, :up
    assert_equal :last, @c_class.sidebars.first[:id]
    assert_equal [:last, :next, :index], @c_class.sidebars.map {|v| v[:id]}
  end
  
  def test_should_reverse_sort_by_default
    standard_sidebars
    assert_equal :index, @c_class.sidebars.first[:id]
    @c_class.sidebar_sort
    assert_equal :last, @c_class.sidebars.first[:id]
    assert_equal [:last, :next, :index], @c_class.sidebars.map {|v| v[:id]}
  end
  
  def test_should_sort_by_arbitrary_keys
    @c_class.sidebar :index, :something => 3
    @c_class.sidebar :next, :something => 5000
    @c_class.sidebar :last, :something => 9
    @c_class.sidebar_sort :something
    assert_equal [:next, :last, :index], @c_class.sidebars.map {|v| v[:id]}
  end
  
  def test_should_sort_by_block
    standard_sidebars
    @c_class.sidebar_sort { |sb1, sb2| sb1[:id].to_s <=> sb2[:id].to_s }
    assert_equal [:index, :last, :next], @c_class.sidebars.map {|v| v[:id]}
  end
  
  protected
  def standard_sidebars
    @c_class.sidebar :index
    @c_class.sidebar :next
    @c_class.sidebar :last
  end

end
