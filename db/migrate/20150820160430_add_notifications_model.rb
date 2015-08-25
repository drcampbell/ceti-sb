class AddNotificationsModel < ActiveRecord::Migration
  def change
  	create_table :notifications do |t|
  		t.integer :user_id
  		t.integer :act_user_id
  		t.integer :event_id
  		t.integer :n_type
  		t.boolean :read
  	end
  end
end
