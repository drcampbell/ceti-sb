class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.string :picture
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
