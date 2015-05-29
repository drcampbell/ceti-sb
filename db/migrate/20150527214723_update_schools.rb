class UpdateSchools < ActiveRecord::Migration
  def change
		add_column :schools, :survey_year, :integer
		add_column :schools, :ncessch, :string
		add_column :schools, :fipst, :string
		add_column :schools, :leaid, :string
		add_column :schools, :schno, :string
		add_column :schools, :stid, :string
		add_column :schools, :seasch, :string
		add_column :schools, :edu_agency, :string
		add_column :schools, :school_name, :string
		add_column :schools, :phone, :string
		add_column :schools, :mail_addr, :string
		add_column :schools, :mail_city, :string
		add_column :schools, :mail_state, :string
		add_column :schools, :mail_zip, :string
		add_column :schools, :mail_zip4, :string
		add_column :schools, :loc_addr, :string
		add_column :schools, :loc_city, :string
		add_column :schools, :loc_state, :string
		add_column :schools, :loc_zip, :string
		add_column :schools, :loc_zip4, :string
		add_column :schools, :type, :integer
		add_column :schools, :status, :integer
		add_column :schools, :union, :string
		add_column :schools, :urban_local, :string
		add_column :schools, :latitude, :decimal, {:precision=>10, :scale=>6}
		add_column :schools, :longitude, :decimal, {:precision=>10, :scale=>6}
		add_column :schools, :county_number, :string
		add_column :schools, :county_name, :string
		add_column :schools, :cdcode, :string
		add_column :schools, :grade_lo, :string
		add_column :schools, :grade_hi, :string
		add_column :schools, :charter, :boolean
  end
end
