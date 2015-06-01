class RemoveExcessLocationFields < ActiveRecord::Migration
  def change
  	remove_column :locations, :user_id
  	remove_column :locations, :school_id
  	remove_column :locations, :badge_id
  end
end
