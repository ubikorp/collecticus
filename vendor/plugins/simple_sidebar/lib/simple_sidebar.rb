# SimpleSidebar
#
# The eponymous SimpleSidebar is a quick and dirty way to create sidebars. See the README for
# examples of usage.
#
module SimpleSidebar

  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end


  class UnknownSidebarError < StandardError
  end
  class UnknownSidebarIdentifier < UnknownSidebarError
  end
  class UnknownSidebarPartial < UnknownSidebarError
  end
#  class UnknownSidebarCondition < UnknownSidebarError
#  end


  module ClassMethods
    
    def sidebars #:nodoc:
      @sidebars ||= []
    end
    def sidebars=(obj) #:nodoc:
      @sidebars = (obj ? obj.compact : [])
    end    
    def sidebars_path #:nodoc:
      @@sidebars_path ||= "#{RAILS_ROOT}/app/views/sidebars"
    end
    
    def sidebars_path=(obj) #:nodoc:
      @@sidebars_path = obj
    end

    # Append a new sidebar to the current controller's sidebars
    #     sidebar :search
    #     sidebar :poll, :component => { :controller => '/poll', :action => 'current' }
    def sidebar(id, options = {})
      options[:id] = id
      sidebars << normalize_sidebar_options(options) unless find_sidebar(options[:id])
    end

    # Delete a sidebar symbol from the current controller's sidebars
    #     sidebar_delete :search
    def sidebar_delete(id)
      if sb_index = find_sidebar_index(id)
        sidebars.delete_at(find_sidebar_index(id))
        sidebars.compact!
      end
    end

    # Clears the sidebars which have been defined so far. Takes :only and :except.
    #
    #   sidebar_clear
    #   sidebar_clear :except => [:login, :search]
    #   sidebar_clear :only => [:login, :search, :general]
    #
    def sidebar_clear(options = {})
      if options[:only]
        sidebars.reject! { |sb| options[:only].include?(sb[:id]) == true }
      elsif options[:except]
        sidebars.reject! { |sb| options[:except].include?(sb[:id]) == false }
      else
        self.sidebars = []
      end
    end

    # Sorts currently defined sidebars. Sorts by key (must be sortable) or block, like Array#sort.
    #
    #   sidebar :search, :priority => 5
    #   sidebar :poll, :priority => 1
    #
    #   sidebar_sort :priority
    #       OR
    #   sidebar_sort { | sb1, sb2 | sb2[:priority] <=> sb1[:priority] }
    #
    #     => [{ :id => :search, :priority => 5 },
    #         { :id => :poll, :priority => 1}]
    #
    # NOTE 1: SimpleSidebar#sidebar_sort without a block or key is the same result as above.
    # NOTE 2: You can pack the sidebar command with unrecognised options to be used for more
    # complex sorting algorithms. As you can see, :priority is reverse sorted in order to handle
    # 'nil' and '0' values properly. If you use sort, be sure everything has a unique priority.
    #
    def sidebar_sort(sort_key = :priority, &block)
      sort_key = sort_key.to_sym
      if block_given?
        sidebars.sort! &block
      else
        sidebars.sort! { |sb1, sb2| sb2[sort_key] <=> sb1[sort_key] }
      end
    end

    # Precisely control the arrangement of sidebars.
    #
    #   sidebar_move :login, :top
    #   sidebar_move :search, :bottom
    #   sidebar_move :search, :up
    #   sidebar_move :login, :down
    #
    def sidebar_move(sidebar, position)
      return unless sidebars
      if sb_index = find_sidebar_index(sidebar)
        case position
        when :top
          new_index = 0
        when :bottom
          new_index = -1
        when :up
          new_index = (sb_index > 0 ? sb_index - 1 : sb_index)
        when :down
          new_index = ((sbs.length - 1) > sb_index ? sb_index + 1 : sb_index)
        else
          new_index = sb_index
        end
        sidebars.insert(new_index, sidebars.delete_at(sb_index)) if new_index != sb_index
      end
    end


    private

    # Finds a particular sidebar according to the value of its :id key (default) or given key.
    def find_sidebar(value, key = :id)
      sidebars.select { |v| v[key] == value }.first
    end

    # Finds the position of a sidebar within the sidebars attribute
    def find_sidebar_index(value, key = :id)
      sidebars.index(find_sidebar(value, key))
    end

    # Finds the next priority in the sidebar chain
    def next_sidebar_priority()
      (sidebars.map { |sb| sb[:priority] if sb[:priority] }.sort.last || 0) + 1
    end

    # Checks the sanity of options which have been set
    def normalize_sidebar_options(options)
      raise UnknownSidebarIdentifier unless options[:id]
      options[:id] = options[:id].to_sym
      raise UnknownSidebarPartial unless options[:component] || File.exist?("#{sidebars_path}/_#{options[:id].to_s}.rhtml")
      options[:only] = normalize_sidebar_conditions(options[:only]) if options[:only] #.to_a.flatten.map { |v| v.to_sym } if options[:only]
      options[:except] = normalize_sidebar_conditions(options[:except]) if options[:except] #.to_a.flatten.map { |v| v.to_sym } if options[:except]
      # raise UnknownSidebarCondition if options[:if] && !respond_to?(options[:if])
      # raise UnknownSidebarCondition if options[:unless] && !respond_to?(options[:unless])
      options[:priority] = next_sidebar_priority unless options[:priority].is_a?(Integer)
      options
    end

    # Ensures method conditionals all exist and are symbols.
    def normalize_sidebar_conditions(*conditionals)
      conditionals.flatten.map { |item| item.to_sym }.compact
      # conditionals.select { |action| respond_to?(action) }
    end
  
  end
  
  # Aliases for class methods so they can be called within a controller action

  def sidebars; self.class.sidebars; end  
  def sidebars=(obj); self.class.sidebars = obj; end
  def sidebars_path; self.class.sidebars_path; end
  def sidebars_path=(obj); self.class.sidebars_path = obj; end  
  def sidebar(*args); self.class.sidebar(*args); end
  def sidebar_delete(*args); self.class.sidebar_delete(*args); end
  def sidebar_clear(*args); self.class.sidebar_clear(*args); end
  def sidebar_move(*args); self.class.sidebar_move(*args); end
  def sidebar_sort(*args, &block); self.class.sidebar_sort(*args, &block); end

  # Selects the sidebars which should be shown
  def sidebars_after_conditions
    sidebars.select { |sb| !sidebar_exempted?(sb) }
  end

  # Checks whether a particular sidebar should be shown or not
  def sidebar_exempted?(sb)
    return true if sb[:only] && !sb[:only].include?(action_name.to_sym)
    return true if sb[:except] && sb[:except].include?(action_name.to_sym)
    return true if sb[:if] && !(self.send(sb[:if]))
    return true if sb[:unless] && self.send(sb[:unless])
    return false
  end

end

module SimpleSidebarHelper
  
  # Render all of your sidebars
  #   <%= render_sidebars %>
  def render_sidebars
    if current_sidebars = @controller.sidebars_after_conditions
      current_sidebars.map do |sb|
        if sb[:component]
          render_component sb[:component]
        else
          render :partial => "#{@controller.sidebars_path.split('/').last}/#{sb[:id].to_s}"
        end
      end.join("\n")
    end
  end

end