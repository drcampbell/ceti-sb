class AddBoolsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :confirmed_by_teacher, :boolean, default: false
    add_column :claims, :confirmed_by_speaker, :boolean, default: false
  end
end
