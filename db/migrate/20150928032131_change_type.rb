class ChangeType < ActiveRecord::Migration
  def change
  	rename_column :badges, :type, :f_type
  end
end
