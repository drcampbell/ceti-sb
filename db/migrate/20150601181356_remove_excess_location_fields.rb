class RemoveExcessLocationFields < ActiveRecord::Migration
  def change
  	remove_column :locations, :user_id, :integer
  	remove_column :locations, :school_id, :integer
  	remove_column :locations, :badge_id, :integer
  end
end
