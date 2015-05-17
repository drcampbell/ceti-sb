class AddColsToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :name, :string
  end
end
