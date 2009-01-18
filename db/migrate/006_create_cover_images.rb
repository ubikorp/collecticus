class CreateCoverImages < ActiveRecord::Migration
  def self.up
    create_table :cover_images do |t|
      t.column :episode_id, :integer
      t.column :parent_id, :integer
      t.column :content_type, :string
      t.column :filename, :string    
      t.column :thumbnail, :string 
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
    end
  end

  def self.down
    drop_table :cover_images
  end
end
