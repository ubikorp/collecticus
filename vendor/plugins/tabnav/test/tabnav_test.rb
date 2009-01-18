require File.dirname(__FILE__) + '/test_helper'

class TabnavTest < Test::Unit::TestCase
  def setup
    @tabnav = :sample.to_tabnav
  end
  
  def test_default_html_options
    assert_equal 'sample_tabnav', @tabnav.html_options[:id]
    assert_equal 'sample_tabnav', @tabnav.html_options[:class]
  end  
end