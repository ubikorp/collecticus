require 'iconv'
module PermalinkFu
  class << self
    attr_accessor :translation_to
    attr_accessor :translation_from
    
    def escape(str)
      s = Iconv.iconv(translation_to, translation_from, str).to_s
      s.gsub!(/\W+/, ' ') # all non-word chars to spaces
      s.strip!            # ohh la la
      s.downcase!         #
      s.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
      s
    end
  end
  
  def has_permalink(attr_names = [], permalink_field = nil)
    permalink_field ||= 'permalink'
    before_validation { |record| record.send("#{permalink_field}=", Array(attr_names).collect { |attr_name| PermalinkFu.escape(record.send(attr_name).to_s) }.join('-')) if record.send(permalink_field).to_s.empty? }

    #before_validation { |record| record.send("#{permalink_field}=", PermalinkFu.escape(record.send(attr_name).to_s)) if record.send(permalink_field).to_s.empty? }
  end
end

PermalinkFu.translation_to   = 'ascii//ignore//translit'
PermalinkFu.translation_from = 'utf-8'
