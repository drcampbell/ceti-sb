class AddNameToBadge < ActiveRecord::Migration
  def change
  	add_column :badges, :name, :string
  end
end
