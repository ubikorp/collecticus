# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 20) do

  create_table "books", :force => true do |t|
    t.column "number",       :integer
    t.column "series_id",    :integer
    t.column "created_at",   :datetime
    t.column "updated_at",   :datetime
    t.column "published_on", :datetime
    t.column "description",  :text
    t.column "type",         :string
    t.column "name",         :string
    t.column "permalink",    :string
    t.column "publisher_id", :integer
    t.column "talent",       :string
  end

  create_table "books_users", :id => false, :force => true do |t|
    t.column "book_id",    :integer,  :default => 0
    t.column "user_id",    :integer,  :default => 0
    t.column "created_at", :datetime
  end

  create_table "comments", :force => true do |t|
    t.column "book_id",    :integer
    t.column "user_id",    :integer
    t.column "body",       :text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "cover_images", :force => true do |t|
    t.column "book_id",      :integer
    t.column "parent_id",    :integer
    t.column "content_type", :string
    t.column "filename",     :string
    t.column "thumbnail",    :string
    t.column "size",         :integer
    t.column "width",        :integer
    t.column "height",       :integer
  end

  create_table "feed_articles", :force => true do |t|
    t.column "feed_source_id", :integer
    t.column "title",          :string
    t.column "created_at",     :datetime
    t.column "published_at",   :datetime
    t.column "author",         :string
    t.column "link",           :string
    t.column "content",        :text
    t.column "category",       :string
  end

  create_table "feed_sources", :force => true do |t|
    t.column "name",       :string
    t.column "url",        :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "publisher_logos", :force => true do |t|
    t.column "publisher_id", :integer
    t.column "parent_id",    :integer
    t.column "content_type", :string
    t.column "filename",     :string
    t.column "thumbnail",    :string
    t.column "size",         :integer
    t.column "width",        :integer
    t.column "height",       :integer
  end

  create_table "publishers", :force => true do |t|
    t.column "name",       :string
    t.column "permalink",  :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "ratings", :force => true do |t|
    t.column "rating",        :integer,                :default => 0
    t.column "created_at",    :datetime,                               :null => false
    t.column "rateable_type", :string,   :limit => 15, :default => "", :null => false
    t.column "rateable_id",   :integer,                :default => 0,  :null => false
    t.column "user_id",       :integer,                :default => 0,  :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"

  create_table "roles", :force => true do |t|
    t.column "name",              :string,   :limit => 40
    t.column "authorizable_type", :string,   :limit => 30
    t.column "authorizable_id",   :integer
    t.column "created_at",        :datetime
    t.column "updated_at",        :datetime
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.column "user_id",    :integer
    t.column "role_id",    :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "series", :force => true do |t|
    t.column "name",         :string
    t.column "permalink",    :string
    t.column "publisher_id", :integer
    t.column "created_at",   :datetime
    t.column "updated_at",   :datetime
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
    t.column "bio",                       :text
    t.column "interests",                 :text
    t.column "location",                  :string
  end

end