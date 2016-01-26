class Addindicestoschools < ActiveRecord::Migration
  def change
    add_index :schools, :school_name
    add_index :schools, :loc_city
    add_index :schools, :loc_state
    add_index :schools, :loc_addr
  end
end
