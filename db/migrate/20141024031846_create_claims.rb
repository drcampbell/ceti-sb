class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.references :event, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
