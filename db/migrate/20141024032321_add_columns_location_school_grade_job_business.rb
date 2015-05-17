class AddColumnsLocationSchoolGradeJobBusiness < ActiveRecord::Migration
  def change
    add_column :users, :school, :string
    add_column :users, :grades, :string
    add_column :users, :job_title, :string
    add_column :users, :business, :string
  end
end
