class AddSchoolIdToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :school_id, :integer
  	add_index :events, :school_id
  end
end
