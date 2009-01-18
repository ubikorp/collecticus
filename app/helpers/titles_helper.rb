module TitlesHelper
  def latest_cover_image_with_link(title, size = :md)
    if title.class == Series
      book = title.latest_episode
    else # not series, is publisher (solobook)
      book = title.latest_solobook
    end
    
    if book.nil? || book.cover_image.nil?
      path = App::Config.send("default_image_path_#{size}")
      image_tag("#{path}")
    else
      link_to(image_tag(book.cover_image.public_filename(size), :border => 0, :alt => "Cover art"), 
              art_path(book), :title => "Click for full-size image", :popup => ['cover_art', 'height=600,width=400'])
    end
  end
end
