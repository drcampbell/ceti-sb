class SetupSearchByLocation < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE EXTENSION cube;
      CREATE EXTENSION earthdistance;
      CREATE INDEX loc_index on schools USING gist(ll_to_earth(latitude, longitude));
    SQL
  end
end
