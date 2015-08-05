class AddUserAndLocNamesToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :user_name, :string
  	add_column :events, :loc_name, :string
  	rename_column :events, :school_id, :loc_id
  end
end
