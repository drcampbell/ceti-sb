class CreateZipcodes < ActiveRecord::Migration
  def change
    create_table :zipcodes do |t|
      t.integer :zip
      t.decimal :lat
      t.decimal :long
    end
  end
end
