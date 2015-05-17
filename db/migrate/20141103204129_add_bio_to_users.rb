class AddBioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :biography, :text
    add_column :users, :speaking_category, :string
  end
end
