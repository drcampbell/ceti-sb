class FixUserSchoolsAssoc < ActiveRecord::Migration
  def change
    remove_column :users, :school
    add_column :users, :school_id, :integer
    add_index :users, :school_id
  end
end
