class AddFieldsToAds < ActiveRecord::Migration
  def self.up
      add_column :ads, :car_make, :string
      add_column :ads, :car_model, :string
      add_column :ads, :car_color, :string
      add_column :ads, :manufacture_year, :string
      add_column :ads, :regn_no, :string
      add_column :ads, :running_km, :string
  end

  def self.down
      remove_column :ads, :car_make
      remove_column :ads, :car_model
      remove_column :ads, :car_color
      remove_column :ads, :manufacture_year
      remove_column :ads, :regn_no
      remove_column :ads, :running_km
  end  
end