class AddSchoolIdRemovePicture < ActiveRecord::Migration
  def change
    add_column :locations, :school_id, :integer
    remove_column :events, :picture
  end
end
