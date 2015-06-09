class RenameEventColumn < ActiveRecord::Migration
  def change
  	rename_column :events, :end, :event_end
  	rename_column :events, :start, :event_start
  end
end
