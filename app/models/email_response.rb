class EmailResponse < ActiveRecord::Base
	enum response_type: [ :bounce, :complaint, :ooto ]

	validates_presence_of :email
end