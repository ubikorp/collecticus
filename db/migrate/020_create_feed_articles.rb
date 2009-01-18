class CreateFeedArticles < ActiveRecord::Migration
  def self.up
    create_table :feed_sources do |t|
      t.column :name, :string
      t.column :url, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    create_table :feed_articles do |t|
      t.column :feed_source_id, :integer
      t.column :title, :string
      t.column :created_at, :datetime
      t.column :published_at, :datetime
      t.column :author, :string
      t.column :link, :string
      t.column :content, :text
      t.column :category, :string
    end
    
    FeedSource.create(
      :name => "Collectic.us News", 
      :url => "http://info.collectic.us/feed/rss20.xml")
  end

  def self.down
    drop_table :feed_articles
    drop_table :feed_sources
  end
end
