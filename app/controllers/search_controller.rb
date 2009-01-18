class SearchController < ApplicationController
  sidebar :login, :unless => :logged_in?
  sidebar :favorite_series
  sidebar :recent_comments
  
  before_filter :build_search_query
  
  SEARCH_TARGETS = {"title"       => "permalink",
                    "talent"      => "talent",
                    "description" => "description"}
  
  # GET /search
  def show
    if params[:query]
      @books = Book.find(:all, :conditions => @query_conditions,
                         :page => {:size => @page_size, :current => @page_number})
    end
  end
  
  # POST /search
  def create
    show
    render(:action => 'show')
  end
  
  protected
  
    def build_search_query
      params[:query] ||= params[:squery]
      if params[:query]
        target = SEARCH_TARGETS[params[:target]] || "permalink"
        @query_conditions = ""
        terms = params[:query].split(' ')
        terms.each do |term|
          @query_conditions += "#{target} LIKE '%#{term}%'"
          @query_conditions += " AND " unless terms.last == term
        end
      end
    end
end
