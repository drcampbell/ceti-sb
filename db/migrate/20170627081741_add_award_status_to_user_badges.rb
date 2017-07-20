class AddAwardStatusToUserBadges < ActiveRecord::Migration
  def change
    add_column :user_badges, :award_status, :smallint
  end
end
