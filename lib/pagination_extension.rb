# This module is used to extend ActiveRecord associations on any model to make 
# use of the pagination capabilities provided by paginating_find.
#
module PaginationExtension
# Return a page of results
  def paginate(current = 1, size = 10, options = {})
    options[:page] = {:current => current, :size => size}
    find(:all, options)
  end
end

