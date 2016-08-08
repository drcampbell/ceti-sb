class AddDeviceTypeToDevice < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE deviceType AS ENUM ('android', 'ios');
    SQL

    add_column :devices, :device_type, :deviceType, default:'android',
      index:true, comment: "Android=0 & IOS=1"
  end
  def down
    remove_column :devices, :device_type

    execute <<-SQL
      DROP TYPE deviceType;
    SQL
  end

end
