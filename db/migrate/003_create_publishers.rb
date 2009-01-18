class CreatePublishers < ActiveRecord::Migration
  def self.up
    create_table :publishers do |t|
      t.column :name, :string
      t.column :permalink, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :publishers
  end
end
