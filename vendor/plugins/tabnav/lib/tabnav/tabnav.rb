require 'singleton'
module Tabnav 
  class Base 
    include Singleton
    attr_accessor :tabs, :html_options
    
    def self.add_tab &block
      raise "you should provide a block" if !block_given? 
        instance.tabs ||= []
        instance.tabs << Tabnav::Tab.new(&block)
    end 
    
    def self.html_options(options) 
      instance.html_options.merge!(options)
    end
    
    private 
    
    def initialize
      @tabs = []
      @html_options = {} # setup default html options
      @html_options[:id] = self.class.to_s.underscore
      @html_options[:class] = @html_options[:id]
    end
  end
end