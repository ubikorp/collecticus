class AddEpisodeTalent < ActiveRecord::Migration
  def self.up
    add_column :episodes, :talent, :string
  end

  def self.down
    remove_column :episodes, :talent
  end
end
