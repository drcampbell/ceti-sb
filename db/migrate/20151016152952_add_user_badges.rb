class AddUserBadges < ActiveRecord::Migration
  def change
  	create_table :user_badges do |t|
  		t.integer :user_id
  		t.string :badge_id
  	end
  end
end
