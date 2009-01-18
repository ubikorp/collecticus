class Symbol
  # Converts :sample in a SampleWizard class
  def to_tabnav
    file_name = self.id2name + '_tabnav'
    eval(file_name.camelcase).instance
  end
end

module Kernel
  def deep_clone( obj=self, cloned={} )
    if cloned.has_key?( obj.object_id )
      return cloned[obj.object_id]
    else
      begin
        cl = obj.clone
      rescue Exception
        # unclonnable (TrueClass, Fixnum, ...)
        cloned[obj.object_id] = obj
        return obj
      else
        cloned[obj.object_id] = cl
        cloned[cl.object_id] = cl
        if cl.is_a?( Hash )
          cl.clone.each { |k,v|
            cl[k] = deep_clone( v, cloned )
          }
        elsif cl.is_a?( Array )
          cl.collect! { |v|
                  deep_clone( v, cloned )
          }
        end
        cl.instance_variables.each do |var|
          v = cl.instance_eval( var )
          v_cl = deep_clone( v, cloned )
          cl.instance_eval( "#{var} = v_cl" )
        end
        return cl
      end
    end
  end
end
