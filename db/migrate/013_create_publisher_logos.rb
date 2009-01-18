class CreatePublisherLogos < ActiveRecord::Migration
  def self.up
    create_table :publisher_logos do |t|
      t.column :publisher_id, :integer
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
    drop_table :publisher_logos
  end
end
