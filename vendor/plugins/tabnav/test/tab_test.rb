require File.dirname(__FILE__) + '/test_helper'

class TabTest < Test::Unit::TestCase

  EXPECTED_INSTANCE_METHODS = %w{named name links_to link highlights_on highlights titled title}
  
  def setup
    @page = FakeView.new
    
    @tab = Tabnav::Tab.new do 
      named 'tab'
      links_to :controller => 'pippo', :action => 'pluto'
    end
    @tab.page=@page
    
    @simple_tab = Tabnav::Tab.new {named 'simple_tab'; links_to :controller =>'pippo' }
    @simple_tab.page = @page
    
    @dyntab = Tabnav::Tab.new do 
      named proc { @myname }
      links_to proc {{:controller => 'pippo', :action => @myname}} 
      highlights_on proc {{:controller => @mysurname}}
    end    
    @dyntab.page = @page 
    
    @empty = Tabnav::Tab.new {named 'empty'}
    
    @conditional = Tabnav::Tab.new {
      named 'conditional'
      links_to :action => 'go'
      show_if proc { @myname.eql?'Paolo'}
    }
    @conditional.page = @page
  end
  
  def test_not_nil
    assert !:sample.to_tabnav.nil?
  end
  
  def test_setup
    assert @tab
    
    assert @page
    assert_equal 'Paolo', @page.instance_eval('@myname')
    
    assert @simple_tab
    assert @simple_tab.page
  
    assert @dyntab
    assert @dyntab.page
    assert @dyntab.instance_eval("@name")
    
    assert @conditional
    assert @conditional.page
  end
  
  def test_initialize
    begin
      t = Tabnav::Tab.new  
      assert false, "should fail without a provided block"
    rescue 
      assert true 
    end
  end
  
  def test_sanity
    tab1 = Tabnav::Tab.new {named 'one'}
    assert !tab1.nil?
    assert 'one', tab1.name
    
    tab2 = Tabnav::Tab.new {named 'two'}
    assert !tab2.nil?
    assert 'two', tab1.name
    
    assert_not_same tab1,tab2
  end
    
  def test_presence_of_instance_methods
    EXPECTED_INSTANCE_METHODS.each do |instance_method|
      assert @tab.respond_to?(instance_method), "#{instance_method} is not defined in #{@tab.inspect} (#{@tab.class})" 
    end     
  end
  
  def test_named 
    assert_equal 'tab', @tab.name
    
    @tab.named 'test2'
    assert_equal 'test2', @tab.name
  end
  
  def test_named_dynamic
    assert_equal 'Paolo', @dyntab.name
    
    @dyntab.named proc { @mysurname  }
    assert_equal 'Dona', @dyntab.name
  end
  
  def test_links_to
    assert_equal({:controller => 'pippo', :action => 'pluto'}, @tab.link)
    
    @tab.links_to :controller => 'pluto'
    assert_equal({:controller => 'pluto'}, @tab.link)
  end
  
  def test_links_to_dynamic
    assert_equal({:controller => 'pippo', :action => 'Paolo'}, @dyntab.link)
    
    @dyntab.links_to proc {{:controller => @mysurname}}  
    assert_equal({:controller => 'Dona'}, @dyntab.link)
  end
  
  def test_highlights_on
    assert_equal [], @empty.highlights, 'should return an empty array'
    @empty.highlights_on :action => 'my_action'
    @empty.highlights_on :action => 'my_action2', :controller => 'my_controller'
    @empty.page=@page
    
    assert @empty.highlights.kind_of?(Array)
    assert_equal 2, @empty.highlights.size, '2 highlights were added so far'
    
    @empty.highlights.each {|hl| assert hl.kind_of?(Hash)}
    
    # sanity check
    assert_equal 'my_action', @empty.highlights[0][:action] 
  end
  
  def test_highlights_on_dynamic 
    assert_equal 2, @dyntab.highlights.size, 'should return 2 elements'
    @dyntab.highlights_on proc {{:action=> @mysurname}}
    @dyntab.highlights_on proc {{:name => @myname, :surname => @mysurname}}
     
    assert @dyntab.highlighted?({:action => 'Dona'})
    assert @dyntab.highlighted?({:name => 'Paolo', :surname => 'Dona'})
    assert @dyntab.highlighted?({:controller => 'pippo', :action => 'Paolo'})
    assert @dyntab.highlighted?({:controller => 'Dona'})
  end
  
  def test_highlighted 
    #check that highlights on its own link
    assert @simple_tab.highlighted?(:controller => 'pippo'), 'should highlight'
    assert @simple_tab.highlighted?(:controller => 'pippo', :action => 'list'),'should highlight'
    
    assert !@simple_tab.highlighted?(:controller => 'pluto', :action => 'list'),'should NOT highlight'
  
    # add some other highlighting rules
    # and check again
    @simple_tab.highlights_on :controller => 'pluto'
    assert @simple_tab.highlighted?(:controller => 'pluto'), 'should highlight'
  
    @simple_tab.highlights_on :controller => 'granny', :action => 'oyster'
    assert @simple_tab.highlighted?(:controller => 'granny', :action => 'oyster'), 'should highlight'
    
    assert !@simple_tab.highlighted?(:controller => 'granny', :action => 'daddy'), 'should NOT highlight'   
  end
  
  def test_highlighted_dynamic 
    #check that highlights on its own link
    assert @dyntab.highlighted?(:controller => 'pippo', :action => 'Paolo'), 'should highlight'
    assert @dyntab.highlighted?(:controller => 'pippo', :action => 'Paolo', :id => "13"),'should highlight'
    
    assert !@dyntab.highlighted?(:controller => 'pluto'), 'should NOT highlight'
    assert !@dyntab.highlighted?(:controller => 'pippo', :action => 'fake'), 'should NOT highlight'
  
    # add some other highlighting rules
    # and check again
    @dyntab.highlights_on :controller => 'pluto'
    assert @dyntab.highlighted?(:controller => 'pluto'), 'should highlight'
  
    @dyntab.highlights_on proc {{ :controller => @mysurname }}
    assert @dyntab.highlighted?(:controller => 'Dona'), 'should highlight'
    
    assert !@dyntab.highlighted?(:controller => 'random'), 'should NOT highlight'   
  end
    
  def test_highlighted_on_highlights 
    assert @simple_tab.highlighted?(:controller => 'pippo')
    assert @simple_tab.highlighted?(:controller => 'pippo', :action => 'list')    
    assert !@simple_tab.highlighted?(:controller => 'pluto', :action => 'list')
  end
  
  def test_show_if_dynamic
    assert @conditional.visible?
  end

  def test_clone_should_really_clone
    @tab.html_options[:class] = 'fake'
    t = @tab.deep_clone
    t.html_options[:class] = 'active'
    assert_equal 'fake', @tab.html_options[:class]
  end
 
end