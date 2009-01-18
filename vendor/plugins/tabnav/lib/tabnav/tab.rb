module Tabnav
  class Tab
    attr_reader :highlights, :link, :name, :title
    attr_accessor :page
    
    def initialize &block
      # I have to keep params and actual values 
      # separated because they have to be re-evaluated each time
      @name = nil
      @title = nil
      @link = {}
      @highlights = []
      @condition = "true"  
      @html_options = {} 
      instance_eval(&block);  
    end
    
    # This is the ActionView Page I need to eval proc objects
    def page=(p)
      @page = p
    end
    
    def page
      raise "You must set a page before calling this method" unless @page
      @page
    end
    
    # setter methods
    # they're used inside the Tabnav definition
   
    # acts as a getter if called without parameters
    def html_options( options=nil )
      @html_options = options if options
      @html_options
    end
    
    def named(name)
      @name = check_string_or_proc(name, 'name')
    end  
     
    def titled(title)
      @title = check_string_or_proc(title, 'title')
    end
         
    def links_to(link={})
      @link = check_hash_or_proc link, 'link'
      highlights_on @link  
    end
        
    def highlights_on(options={})
      @highlights << check_hash_or_proc(options, 'highlight_on options')
    end
    
    def show_if(condition)
      @condition = check_string_or_proc(condition, 'condition')
    end
    
    # getter methods
    # they evaluate a proc against the page or return directly the param
    
    def name
      result = @name.kind_of?(Proc) ? page.instance_eval(&@name) : @name
      check_string result, 'name'
    end
    
    def title
      result = @title.kind_of?(Proc) ? page.instance_eval(&@title) : @title
      check_string result, 'title'
    end
    
    def link
      result = @link.kind_of?(Proc) ? page.instance_eval(&@link) : @link 
      check_hash result, 'link'
    end
      
    # Utility methods
    
    def visible?
      if @condition.kind_of?(String)
        result = page.instance_eval(@condition)
      elsif @condition.kind_of?(Proc)
        result = page.instance_eval(&@condition)
      end
      return result 
    end
    
    # takes in input a Hash (usually params)
    # or a string/Proc that evaluates to true/false
    # it does ignore some params like 'only_path' etc..
    # we have to do this to support restful routes
    def highlighted? options={}
      option = clean_unwanted_keys(options)
      #puts "### '#{name}'.highlighted? #{options.inspect}"
      result = false
       
      @highlights.each do |highlight| # for every highlight(proc or hash)
        highlighted = true
        h = highlight.kind_of?(Proc) ?  page.instance_eval(&highlight) : highlight # evaluate highlights
        if (h.is_a?(TrueClass) || h.is_a?(FalseClass))
          highlighted &= h
        else
          check_hash h, 'highlight'
          h = clean_unwanted_keys(h)
          #puts "# #{h.inspect}"
          h.each_key do |key|   # for each key
            highlighted &= h[key].to_s==options[key].to_s   
          end 
        end
        result |= highlighted
      end
      return result
    end
       
    private 
    
    def check_string_or_proc(param, param_name)
      unless param.kind_of?(String) or param.kind_of?(Proc) 
        raise "param #{param_name} should be a String or a Proc but is a #{param.class}"
      end 
      param 
    end
    
    def check_hash_or_proc(param, param_name)
      unless param.kind_of?(Hash) or param.kind_of?(Proc) 
        raise "param #{param_name} should be a Hash or a Proc but is a #{param.class}"
      end
      param 
    end
    
    def check_string(param, param_name)
      return if param.nil?
      raise "param #{param_name} should be a String but is a #{param.class}" unless param.kind_of?(String)  
      param
    end
    
    def check_hash(param, param_name)
      raise "param '#{param_name}' should be a Hash but is #{param.inspect}" unless param.kind_of?(Hash)
      param
    end
    
    # removes unwanted keys from a Hash 
    # and returns a new hash
    def clean_unwanted_keys(hash)
      ignored_keys = [:only_path, :use_route]
      hash.dup.delete_if{|key,value| ignored_keys.include?(key)}
    end 
  end
end