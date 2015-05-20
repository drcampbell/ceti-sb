class AddIndexToLocationsName < ActiveRecord::Migration
  def change
  	add_index :locations, :name
  end
end
