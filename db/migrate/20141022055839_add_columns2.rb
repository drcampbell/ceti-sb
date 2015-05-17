class AddColumns2 < ActiveRecord::Migration
  def change
    add_column :events, :title, :string
    add_column :events, :description, :text
    add_column :events, :picture,  :string
  end
end
