class RemoveColsFromSchools < ActiveRecord::Migration
  def change
    remove_column :schools, :location_id
    remove_column :schools, :user_id
  end
end
