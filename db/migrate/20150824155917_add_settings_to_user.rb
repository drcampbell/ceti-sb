class AddSettingsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :set_updates, :boolean
  	add_column :users, :set_confirm, :boolean
  	add_column :users, :set_claims, :boolean
  end
end
