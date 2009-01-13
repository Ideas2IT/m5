class CreateCars < ActiveRecord::Migration
  def self.up
    create_table :cars do |t|
      t.string :model
      t.integer :price
      t.integer :parent_category_id
      t.timestamps
    end
   
  end

  def self.down
    drop_table :cars
  end
end
