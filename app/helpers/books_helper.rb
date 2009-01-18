module BooksHelper  
  def my_collection_link(book, show_text = true)
    if logged_in?
      label_ok = "&#10003;"
      label_ok += " Pulled" if show_text
      label_add = "&#10010;"
      label_add += " Pull Book" if show_text
      
      if current_user.books.include?(book)
        "<div id=\"status-#{book.permalink.underscore}\" class=\"collection-status-ok\">#{label_ok}</div>"
      else
        "<div id=\"status-#{book.permalink.underscore}\" class=\"collection-status-add\">" +
          link_to_remote(label_add, 
                         { :url => pull_path(book), 
                           :success => "$('status-#{book.permalink.underscore}').update('#{label_ok}').addClassName('collection-status-ok').removeClassName('collection-status-add')" }, 
                         :name => 'add-to-pull-list', 
                         :title => 'Add this book to your pull list') +
          "</div>"
      end
    else
      # nothing to display
    end
  end
  
  def delete_book_link(book)
    "<div id=\"status-#{book.permalink.underscore}\" class=\"collection-status-del\">" +
      link_to_remote("x", 
                     { :url => unpull_path(book),
                       :success => "$('tr-#{book.permalink.underscore}').remove()"},
                     :name => 'remove-from-pull-list',
                     :title => 'Remove this book from your pull list') +
      "</div>"
  end
  
  def unpull_path(book)
    unpull_url = { :controller => 'books', :action => 'unpull', :id => book }
    if book.episode?
      unpull_url[:comic_id] = book.series.publisher
      unpull_url[:title_id] = book.series
    else
      unpull_url[:comic_id] = book.publisher
    end
    unpull_url
  end
  
  def pull_path(book)
    pull_url = { :controller => 'books', :action => 'pull', :id => book }
    if book.episode?
      pull_url[:comic_id] = book.series.publisher
      pull_url[:title_id] = book.series
    else
      pull_url[:comic_id] = book.publisher
    end
    pull_url
  end
  
  def art_path(book)
    book.episode? ? art_comic_title_episode_path(book.series.publisher, book.series, book) : art_comic_book_path(book.publisher, book)
  end
  
  def cover_image_with_link(book, size = :md, image_options = {})
    if book.cover_image.nil?
      cover_image(book, size, image_options)
    else
      link_to(cover_image(book, size, image_options), art_path(book), :title => "Click for full-size image", :popup => ['cover_art', 'height=600,width=400,scrollbars=no,resizable=no'])
    end    
  end
  
  def cover_image(book, size = :md, options = {})
    if book.cover_image.nil?
      path = App::Config.send("default_image_path_#{size}")
      image_tag("#{path}", options)
    else
      image_tag(book.cover_image.public_filename(size), { :border => 0, :alt => "Cover art" }.merge(options))
    end
  end
end
