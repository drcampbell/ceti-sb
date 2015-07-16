class AddStatusToClaims < ActiveRecord::Migration
  def change
  	add_column :claims, :status, :integer
  end
end
