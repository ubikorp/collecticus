class RemoveCommentSubject < ActiveRecord::Migration
  def self.up
    remove_column :comments, :subject
  end

  def self.down
    add_column :comments, :subject, :string
  end
end
