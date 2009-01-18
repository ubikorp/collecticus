module Tabnav
  module TabnavHelper  
    protected 

    # renders the tabnav
    def tabnav(tabnav_sym)
      tn = tabnav_sym.to_tabnav
      tabs = tn.tabs
      
      result =  tag('div', tn.html_options ,true)
      result << tag('ul', {} , true)
      tabs.each do |t|      
        tab = t.deep_clone # I need this in order to avoid binding sharing issues 
        tab.page=self
            
        if tab.visible?
           tab.html_options[:class] = 'active' if tab.highlighted?(params)
           tab.html_options[:title] = tab.title if tab.title
           
           li_options = tab.html_options[:id] ? {:id => tab.html_options[:id] + '_container'} : {} 
           li_options = tab.html_options[:class] ? {:class => tab.html_options[:class]} : {}
           result << tag('li', li_options, true)
           if tab.link.empty?
             result << content_tag('span', tab.name, tab.html_options) 
           else
             result << link_to(tab.name, tab.link, tab.html_options)
           end
           result << "</li> \n" 
        end 
      end 
      result << "</ul></div>"
      
      css = ''
      begin 
        css = capture do
          render  :partial => "tabnav/#{tn.html_options[:class]}", 
                          :locals => { :tabs => tabnav_sym.to_tabnav.tabs }
        end
      rescue
      end
      
      result + css  
    end
    
    # adds the content div
    def start_tabnav(tabnav_sym)
      tn = tabnav_sym.to_tabnav
      result = tabnav(tabnav_sym) 
      result << "\n"
      result << tag('div', {:id => tn.html_options[:id] + '_content',
                            :class => tn.html_options[:class] + '_content'}, true)
      result 
    end
    
    def end_tabnav
      "</div>"
    end
  end 
end
