class AddCanceledToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :active, :boolean
  end
end
