class AddFileToBadges < ActiveRecord::Migration
  def change
  	drop_table(:badges)
  	create_table :badges do |t|
  		t.string :file
      t.timestamps null: false
    end
  end
end
