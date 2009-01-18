# This module is used to extend ActiveRecord associations (Episodes) on the 
# Series model, allowing results to be filtered by the Episode status in a
# given user's collection.
#
module CollectedByExtension
# Return results filtered by user collection status
  def collected_by(user)
    find(:all, :select => "books.*", 
           :joins => "INNER JOIN books_users ON books.id = books_users.book_id",
           :conditions => ["books_users.user_id = ?", user.id])
  end
end

