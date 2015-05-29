class RenameSchoolType < ActiveRecord::Migration
  def change
  	rename_column :schools, :type, :school_type
  	#change_column :schools, :latitude, :string
  	#change_column :schools, :longitude, :string
  end
end
