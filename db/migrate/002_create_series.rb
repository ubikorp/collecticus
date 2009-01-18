class CreateSeries < ActiveRecord::Migration
  def self.up
    create_table :series do |t|
      t.column :name, :string
      t.column :permalink, :string
      t.column :publisher_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :series
  end
end
