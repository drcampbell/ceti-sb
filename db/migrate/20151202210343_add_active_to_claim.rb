class AddActiveToClaim < ActiveRecord::Migration
  def change
  	add_column :claims, :active, :boolean, :default => true
  	add_column :claims, :rejected, :boolean, :default => false
  end
end
