class AddDevicesModel < ActiveRecord::Migration
  def change
  	create_table :devices do |t|
  		t.integer :user_id
  		t.string :device_name
  		t.string :token
  	end
  end
end
