require File.dirname(__FILE__) + '/test_helper'

class TabnavHelperTest < Test::Unit::TestCase

  def setup
    @view = FakeView.new
    @view.extend ApplicationHelper
  end
    
  def test_presence_of_instance_methods
    %w{tabnav start_tabnav end_tabnav}.each do |instance_method|
      assert @view.respond_to?(instance_method), "#{instance_method} is not defined in #{@controller.inspect}" 
    end     
  end  
  
end