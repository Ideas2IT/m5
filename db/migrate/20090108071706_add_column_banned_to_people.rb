class AddColumnBannedToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :banned, :boolean
  end

  def self.down
    remove_column :people, :banned
  end
end
