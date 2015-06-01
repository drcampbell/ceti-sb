class AddEventsToSchool < ActiveRecord::Migration
  def change
  	add_column :schools, :events, :integer
  	add_index :schools, :events
  end
end
