class AddColumns < ActiveRecord::Migration
  def change
    remove_column :events, :title
    remove_column :events, :description
    remove_column :events, :picture
  end
end
