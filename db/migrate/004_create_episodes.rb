class CreateEpisodes < ActiveRecord::Migration
  def self.up
    create_table :episodes do |t|
      t.column :number, :integer
      t.column :series_id, :integer
      t.column :title, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :published_on, :datetime
    end
  end

  def self.down
    drop_table :episodes
  end
end
