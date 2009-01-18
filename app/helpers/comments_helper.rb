module CommentsHelper
  def comments_path(book, options = {})
    if book.episode?
      url_for({ :controller => 'comments', 
                :action => 'index',
                :comic_id   => book.series.publisher,
                :title_id   => book.series,
                :episode_id => book }.merge(options))
    else
      url_for({ :controller => 'comments', 
                :action => 'index',
                :comic_id   => book.publisher,
                :book_id    => book }.merge(options))
    end
  end
end
