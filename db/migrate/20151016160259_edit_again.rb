class EditAgain < ActiveRecord::Migration
  def change
  	remove_column :user_badges, :badge_id
  	add_column :user_badges, :badge_id, :integer
  end
end
