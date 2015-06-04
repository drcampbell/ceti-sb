module UsersHelper
	def isadmin(user)
		user.role == 0
	end
end