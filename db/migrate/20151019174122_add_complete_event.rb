class AddCompleteEvent < ActiveRecord::Migration
  def change
  	add_column :events, :complete, :boolean
  end
end
