class CreateBooksUsers < ActiveRecord::Migration
  def self.up
    create_table :books_users, :id => false, :force => true do |t|
      t.column :book_id, :integer, :default => 0
      t.column :user_id, :integer, :default => 0
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :books_users
  end
end
