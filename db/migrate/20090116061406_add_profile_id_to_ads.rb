class AddProfileIdToAds < ActiveRecord::Migration
  def self.up
      add_column :ads, :profile_id, :string
      add_column :ads, :price, :string
  end

  def self.down
      remove_column :ads, :profile_id
      remove_column :ads, :price
  end  
end