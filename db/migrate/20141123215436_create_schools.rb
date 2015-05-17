class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.references :badge, index: true
      t.references :user, index: true
      t.references :location, index: true

      t.timestamps null: false
    end
  end
end
