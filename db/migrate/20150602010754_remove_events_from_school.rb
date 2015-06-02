class RemoveEventsFromSchool < ActiveRecord::Migration
  def change
  	remove_column :schools, :events, :integer
  end
end
