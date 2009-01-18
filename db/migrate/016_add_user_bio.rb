class AddUserBio < ActiveRecord::Migration
  def self.up
    add_column :users, :bio, :text
    add_column :users, :interests, :text
    add_column :users, :location, :string
  end

  def self.down
    remove_column :users, :bio
    remove_column :users, :interests
    remove_column :users, :location
  end
end
