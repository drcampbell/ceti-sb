class AddCancelledToClaim < ActiveRecord::Migration
  def change
  	add_column :claims, :cancelled, :boolean, default: true
  end
end
