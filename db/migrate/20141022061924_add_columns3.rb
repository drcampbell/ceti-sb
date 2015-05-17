class AddColumns3 < ActiveRecord::Migration
  def change
    add_column :events, :content, :text
  end
end
