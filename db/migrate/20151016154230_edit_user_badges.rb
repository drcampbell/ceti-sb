class EditUserBadges < ActiveRecord::Migration
  def change
  	change_column :user_badges, :badge_id, :integer
  end
end
