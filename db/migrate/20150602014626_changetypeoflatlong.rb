class Changetypeoflatlong < ActiveRecord::Migration
  def change
  	change_column :schools, :latitude, :float
  	change_column :schools, :longitude, :float
  end
end
