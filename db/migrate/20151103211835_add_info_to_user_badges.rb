class AddInfoToUserBadges < ActiveRecord::Migration
  def change
  	add_column :user_badges, :event_id, :integer
  end
end
