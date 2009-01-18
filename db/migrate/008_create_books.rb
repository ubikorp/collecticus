class CreateBooks < ActiveRecord::Migration
  def self.up
    rename_table :episodes, :books
    add_column :books, :type, :string
    add_column :books, :name, :string
    add_column :books, :permalink, :string
    add_column :books, :publisher_id, :integer
    
    rename_column :cover_images, :episode_id, :book_id
  end

  def self.down
    remove_column :books, :publisher_id
    remove_column :books, :permalink
    remove_column :books, :name
    remove_column :books, :type
    rename_table :books, :episodes
    
    rename_column :cover_images, :book_id, :episode_id
  end
end
