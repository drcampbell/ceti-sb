class AddBadgeIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :badge_id, :integer
  end
end
