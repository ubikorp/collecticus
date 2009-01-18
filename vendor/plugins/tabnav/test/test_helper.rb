RAILS_ENV = 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'
require 'breakpoint'
require 'seesaw_tabnav'


# Mocks

class FakeView < ActionView::Base
  include Tabnav::TabnavHelper
  def initialize
   @myname = 'Paolo'
   @mysurname = 'Dona'
  end 
end

class SampleTabnav < Tabnav::Base
  add_tab do 
    named 'Tab One'
    links_to :action => 'prova'
    highlights_on  :action => 'prova'
    highlights_on  :controller => 'pippo', :action => 'prova2'
  end 
end