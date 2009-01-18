module RatingsHelper
  # generate a link_to_remote for the book, given the star to represent (and css class name)
  # for ratings partial
  def rate_star(book, stars = 1, class_name = "one-star")
    url = { :controller => 'ratings', :action => 'create', :rating => stars }

    if book.episode?
      url.merge!({ :comic_id => book.series.publisher, :title_id => book.series, :episode_id => book })
    else
      url.merge!({ :comic_id => book.publisher, :book_id => book })
    end
    
    description = (stars == 1) ? "1-star-out-of-5" : "#{stars}-stars-out-of-5"    
    link_to_remote(stars.to_s, { :url => url }, :class => class_name, :name => description)
  end

  # return the user's personal rating of a book (or return nil)
  # for ratings partial
  def user_rating(book)
    if logged_in? and book.rated_by_user?(current_user)
      book.ratings.find(:first, :conditions => ["user_id = ?", current_user.id]).rating
    else
      0
    end
  end
  
  # return either the average value or the user's own personal rating (if he's rated the book)
  def book_rating(book)
    user_rating = user_rating(book)
    if user_rating == 0
      book.rating || 0
    else
      user_rating
    end
  end
  
  # return the formatted rating value to use in the ratings partial
  def formatted_book_rating(book)
    number_with_precision(book_rating(book), 1)
  end

  # determine the css class to use, based on whether or not the user has rated this item
  # for ratings partial
  def rated_class_name(book)
    if !logged_in? or !book.rated_by_user?(current_user)
      class_name = 'current-rating'
    else
      class_name = 'current-rating-rated'
    end
  end
end
