require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'url_upload'
require 'rubypants'

# This class updates our release database from he remote sources
class ZapUpdater
  URL_Vertigo   = "http://www.dccomics.com/vertigo/comics/"
  URL_Wildstorm = "http://dccomics.com/comics/"
  URL_DC        = "http://www.dccomics.com/dcu/comics/" # ?dat=20070618
  URL_DC_Media  = "http://www.dccomics.com/"
  URL_Marvel    = "http://www.marvel.com"  # /catalog/?date=2007-06-20

  TITLE_CONVERSION_LIST = {
    "Punisher War Journal 9" => "Punisher War Journal",
    "Fallen Son: Death Of Captain America" => "Fallen Son: Death Of Captain America",
    "Fallen Son: The Death of Captain America" => "Fallen Son: Death of Captain America",
    "Captain America: The Chosen 4 Charest (50/50)" => "Captain America: The Chosen",
    "Civil War: Fallen Son" => "Fallen Son: Death Of Captain America",
    "Annihilation: Conquest Star Lord" => "Annihilation: Conquest Starlord",
    "Outsiders: Five Of A Kind: Week" => "Outsiders: Five Of A Kind",
    "Batman Annual:" => "Batman Annual",
    "Franklin Richards: World Be" => "Franklin Richards: World Be Warned",
    "Daredevil Turner" => "Daredevil",
    "Laurell K. Hamilton's Anita Blake - Vampire Hunter: The First Death" => "Anita Blake, Vampire Hunter: The First Death",
    "Marvel Spotlight: Halo" => "Marvel Spotlight: Halo",
    "Marvel Spotlight: " => "Marvel Spotlight",
    "Mystic Arcana: " => "Mystic Arcana",
    "Mythos:" => "Mythos",
    "Powers Encyclopedia Vol. #1" => "Powers Encyclopedia Vol. 1",
    "Super-Villain Team-Up/M.O.D.O.K.'s 11" => "Super-Villain Team-Up/MODOK's 11",
    "Wolverine: Origins" => "Wolverine: Origins",
    "Gen <Sup>13</Sup>: Armageddon" => "Gen13: Armageddon",
    "Gen <Sup>13</Sup>" => "Gen13",
    "World War Hulk: Warbound" => "WWH Aftersmash: Warbound",
    "World War Hulk: Damage Control" => "WWH Aftersmash: Damage Control",
    "Ultimate Fantastic Four 50 White Cover" => "Ultimate Fantastic Four",
    "Captain Britain and MI: 13" => "Captain Britain and MI: 13",
    "Amazing Spider-Man Variant" => "Amazing Spider-Man"
  }
  
  attr_accessor :mail_log
  
  def initialize
    @mail_log = ""
  end
  
  def self.update
    updater = ZapUpdater.new
    
    date = Time.now.beginning_of_week.tomorrow.tomorrow - 1.week + 12.hours # new releases on wednesdays, + 12 hours to avoid DST hehe

    updater.update_marvel(date)
    updater.update_dc(date)
    updater.update_vertigo(date)
    updater.update_wildstorm(date)
    
    puts updater.mail_log
    email = StatusNotifier.create_releases_update_email(updater.mail_log)
    email.set_content_type("text/html")
    StatusNotifier.deliver(email)
  end
  
  # update database with latest Marvel releases
  def update_marvel(date)
    release_date = date
    publisher = Publisher.find_or_create_by_name("Marvel")
    
    while release_date <= date + 4.months do
      log("retrieving marvel data for #{release_date.strftime('%Y-%m-%d')}")
      doc = Hpricot(open("#{URL_Marvel}/catalog/?date=#{release_date.strftime('%Y-%m-%d')}"))
      books = (doc/"a[@class=title_link]")
      books = books.each { |book| fetch_title_marvel(publisher, book.innerHTML.strip, "#{URL_Marvel}#{book.attributes['href']}", release_date) }
      release_date += 1.week
    end
  end
  
  # update database with latest DC releases
  def update_dc(date)
    release_date = date
    publisher = Publisher.find_or_create_by_name("DC")
    
    while release_date <= date + 4.months do
      log("retrieving dc data for #{release_date.strftime('%Y%m%d')}")
      doc = Hpricot(open("#{URL_DC}?dat=#{release_date.strftime('%Y%m%d')}"))
      books = doc/"a[@href*='\?cm\=']"
      books = books.each { |book| fetch_title_dc(publisher, book.innerHTML.strip, "#{URL_DC}#{book.attributes['href']}") }
      release_date += 1.month # dc listings by month
    end
  end
  
  def update_vertigo(date)
    release_date = date
    publisher = Publisher.find_or_create_by_name("Vertigo")
    
    while release_date <= date + 4.months do
      log("retrieving vertigo data for #{release_date.strftime('%Y%m%d')}")
      doc = Hpricot(open("#{URL_Vertigo}?dat=#{release_date.strftime('%Y%m%d')}"))
      books = doc/"a[@href*='\?cm\=']"
      books = books.each { |book| fetch_title_dc(publisher, book.innerHTML.strip, "#{URL_Vertigo}#{book.attributes['href']}") }
      release_date += 1.month # dc listings by month
    end
  end
  
  def update_wildstorm(date)
    release_date = date
    publisher = Publisher.find_or_create_by_name("Wildstorm")
    
    while release_date <= date + 4.months do
      log("retrieving wildstorm data for #{release_date.strftime('%Y%m%d')}")
      doc = Hpricot(open("#{URL_Wildstorm}?s=33&dat=#{release_date.strftime('%Y%m%d')}"))
      books = doc/"a[@href*='\?cm\=']"
      books = books.each { |book| fetch_title_dc(publisher, book.innerHTML.strip, "#{URL_DC}#{book.attributes['href']}") }
      release_date += 1.month # dc listings by month
    end
  end

  private
  
    # fetch details and create/update model for a particular DC title
    def fetch_title_dc(publisher, title, url, date = nil)
      log("retrieving title information for [#{title}]", :debug)
      doc = Hpricot(open(url))
      
      # span.display_talent = "Written by, Art by... "
      # span.display_copy = "A final confrontation pits..."
      # span.display_data = "DC Universe &nbsp;|&nbsp;32pg.  &nbsp;|&nbsp;&nbsp;Color &nbsp;|&nbsp;&nbsp;$2.99&nbsp;US"
      # span.display_copy = "On sale June     6, 2007"
      
      display_talent = ((doc/"#content-col2")/"p:first strong").innerHTML
      display_copy = (doc/"#content-col2").innerHTML
      display_date = ((doc/"#content-col2")/"p:last").innerHTML
      
      title = RubyPants.new(title, -1).to_html
      display_name, display_number = title.split('#')
      display_name = check_title(display_name)
      display_number = display_number.split(' ')[0] unless display_number.nil?
      
      new_record = false
      
      if display_number.nil?
        # SoloBook
        model = SoloBook.find_by_name(display_name)        

        if model.nil?
          model = SoloBook.new(:name => display_name, 
                               :publisher => publisher)
          new_record = true
        end
        
      else
        # Episode
        series = Series.find_by_name(display_name)
        
        if series.nil?
          # Series doesn't exist, create new Series
          series = Series.create!(:name => display_name, 
                                  :publisher => publisher)
          log("created new series [#{display_name}]", :info)
          model = series.episodes.build({ :number => display_number })
          new_record = true
        else
          # Add episode to existing series
          if series.find_episode(display_number).nil?
            model = series.episodes.build({ :number => display_number })
            new_record = true
          else
            model = series.find_episode(display_number)
          end
        end
      end
            
      model.talent = html2text(display_talent)
      model.description = html2text(display_copy)
      model.published_on = Date.parse(display_date.downcase.sub('on sale', '').gsub(/\s+/, ' ').strip)
      
      model.save!
      new_record ? log("created new book [#{title}]", :info) : log("updated existing book [#{title}]", :debug)
      
      if model.cover_image.nil?
        # get cover image (if we don't have one already)
        image_element = (doc/"img").select { |elem| elem.attributes['src'].match(/media\/product\/.*180x270.jpg/) }
        image_url = nil

        unless image_element.empty?
          image_url = image_element[0].attributes['src']
          image_url = "#{URL_DC_Media}#{image_url.gsub(/180x270/,'400x600')}" # full size art
        end

        get_cover_image(model, image_url)
      end
            
    rescue ActiveRecord::RecordInvalid => e
      log("failed to create or update book [#{title}]", :info)
      log("errors: #{model.errors.full_messages.join(', ')}", :info)
      return false
    end
    
    # fetch details and create/update model for a particular DC title
    def fetch_title_marvel(publisher, title, url, date = nil)      
      log("retrieving title information for [#{title}]", :debug)
      doc = Hpricot(open(url))
      
      display_description = (doc/"font[@class=plain_text]").innerHTML

      title = RubyPants.new(title, -1).to_html
      display_name, display_number = title.split('#')
      display_name = check_title(display_name)
      display_number = display_number.split(' ')[0] unless display_number.nil?
            
      new_record = false
      
      if display_number.nil?
        # SoloBook
        model = SoloBook.find_by_name(display_name)
        
        if model.nil?
          model = SoloBook.new(:name => display_name, 
                               :publisher => publisher)
          new_record = true
        end
        
      else
        # Episode
        series = Series.find_by_name(display_name)
        
        if series.nil?
          # Series doesn't exist, create new Series
          series = Series.create!(:name => display_name, 
                                  :publisher => publisher)
          log("created new series [#{display_name}]", :info)
          model = series.episodes.build({ :number => display_number })
          new_record = true
        else
          # Add episode to existing series
          if series.find_episode(display_number).nil?
            model = series.episodes.build({ :number => display_number })
            new_record = true
          else
            model = series.find_episode(display_number)
          end
        end
      end
      
      display_talent, display_description = display_description.split("<strong>THE STORY:</strong>")
      display_description ||= "" # if description was empty make sure it's non-nil
      display_description = display_description.split("<strong>PRICE:</strong>")[0]
      
      model.talent = html2text(display_talent).strip.titleize
      model.description = html2text(display_description).strip
      model.published_on = date
      
      model.save!
      new_record ? log("created new book [#{title}]", :info) : log("updated existing book [#{title}]", :debug)
      
      if model.cover_image.nil?
        # get cover image (if we don't have one already)
        image_element = (doc/"img").select { |elem| elem.attributes['src'].match(/thumb/) }
        image_url = nil
        
        unless image_element.empty?
          image_url = image_element[0].attributes['src']
          image_url = "#{URL_Marvel}#{image_element[0].attributes['src'].gsub('_thumb', '_full')}" # full size art
        end
        
        get_cover_image(model, image_url)
      end
      
    rescue ActiveRecord::RecordInvalid => e
      log("failed to create book [#{title}]", :info)
      log("errors: #{model.errors.full_messages.join(', ')}", :info)
      return false
    end
    
    # update cover image for a specified model
    def get_cover_image(book, url)
      if not url.nil?
        name = book.name || "#{book.series.name} \##{book.number}"
        log("attempting to retrieve cover art [#{url}]", :debug)
        cover_image = book.build_cover_image(:uploaded_data => UrlUpload.new(url))
        if cover_image.save
          log("successfully added cover art [#{name}]", :debug)
        else
          log("unable to add cover art [#{name}]", :debug)
        end
      else
        log("invalid URL for cover art [#{name}]", :debug)
      end
    rescue OpenURI::HTTPError
      log("cover art not found [#{name}]", :debug)
    end
    
    # replace name with the converted value in TITLE_CONVERSION_LIST if it's
    # been flagged for modification (due to an improper solicitation, etc)
    def check_title(name)
      # titleize without the botched 'S (apostrophe-s) issue
      name = name.humanize.strip.squeeze(' ').gsub(/\b([a-z])/) { $1.capitalize }.gsub(/\'S/, '\'s')

      match = TITLE_CONVERSION_LIST.keys.select { |t| name.match(/#{Regexp.escape(t)}/i) }
      unless match.empty?
        match = match.sort.reverse[0] # select the longest match (most accurate)
        name = TITLE_CONVERSION_LIST[match]
      end

      log("checked display name is [#{name}]", :debug)
      name
    end
        
    # convert issue description data from html to text
    # TODO: this method is a mess. clean it up.
    def html2text(html)
      html ||= "" # ensure string is non-nil
      text = html.
        gsub(/(&nbsp;|\n|\s)+/im, ' ').squeeze(' ').strip.
        gsub(/<([^\s]+)[^>]*(src|href)=\s*(.?)([^>\s]*)\3[^>]*>\4<\/\1>/i, '\4')

      linkregex = /<[^>]*(src|href)=\s*(.?)([^>\s]*)\2[^>]*>\s*/i
      while linkregex.match(text)
        text.sub!(linkregex, "")
      end
      
      text = CGI.unescapeHTML(
        text.
          gsub(/<(script|style)[^>]*>.*<\/\1>/im, '').
          gsub(/<!--.*-->/m, '').
          gsub(/<hr(| [^>]*)>/i, "___\n").
          gsub(/<li(| [^>]*)>/i, "\n* ").
          gsub(/<blockquote(| [^>]*)>/i, '> ').
          gsub(/<(br)(| [^>]*)>/i, "\n").
          gsub(/<(\/h[\d]+|p)(| [^>]*)>/i, "\n\n").
          gsub(/<[^>]*>/, '')
      ).lstrip.gsub(/\n[ ]+/, "\n") + "\n"

      converted = []
      text.split(//).collect { |c| converted << ( c[0] > 127 ? "&##{c[0]};" : c ) }
      converted.join('')
    end
  
    # log to standard logger facility and dump to stdout too
    def log(msg, level = :info)
      puts("ZapUpdater: " + msg)
      RAILS_DEFAULT_LOGGER.info("ZapUpdater: " + msg)
      @mail_log << msg + "<br/>\r\n" if level == :info
    end
end
