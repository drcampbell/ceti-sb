class AddStartToEvents < ActiveRecord::Migration
  def change
    add_column :events, :start, :datetime
    add_column :events, :end, :datetime
  end
end
