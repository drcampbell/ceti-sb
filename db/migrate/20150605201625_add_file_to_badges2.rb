class AddFileToBadges2 < ActiveRecord::Migration
  def change
  	create_table :badges do |t|
  		t.string :file
      t.timestamps null: false
    end
  end
end
