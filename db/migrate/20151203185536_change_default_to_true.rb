class ChangeDefaultToTrue < ActiveRecord::Migration
  def change
  	change_column :claims, :cancelled, :boolean, default: false
  end
end
