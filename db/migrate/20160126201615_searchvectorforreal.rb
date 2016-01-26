class Searchvectorforreal < ActiveRecord::Migration
  def up
    # Add search vector column
    add_column :schools, :search_vector, 'tsvector'
    # Add gin index on the search vector
    execute <<-SQL
      CREATE INDEX schools_search_idx
      ON schools
      USING gin(search_vector);
    SQL

    # Trigger to update vector column when updated
    execute <<-SQL
      DROP TRIGGER IF EXISTS schools_search_vector_update
      ON schools;
      CREATE TRIGGER schools_search_vector_update
      BEFORE INSERT OR UPDATE
      ON schools
      FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger (search_vector, 'pg_catalog.english', school_name, loc_addr, loc_city, loc_state);
    SQL

    School.find_each {|s| s.touch}
  end
  
  def down
    remove_column :schools, :search_vector
    execute <<-SQL
      DROP TRIGGER IF EXISTS schools_search_vector_update on schools;
    SQL
  end
end
