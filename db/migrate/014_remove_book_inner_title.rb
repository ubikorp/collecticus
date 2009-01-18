class RemoveBookInnerTitle < ActiveRecord::Migration
  def self.up
    remove_column :books, :title
  end

  def self.down
    add_column :books, :title, :string
  end
end
