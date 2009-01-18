class AddEpisodeDescription < ActiveRecord::Migration
  def self.up
    add_column :episodes, :description, :text
  end

  def self.down
    remove_column :episodes, :description
  end
end
