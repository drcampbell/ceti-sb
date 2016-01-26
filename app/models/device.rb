class Device < ActiveRecord::Base
	belongs_to :user

	def register_endpoint 
		begin
      sns = Aws::SNS::Client.new(region: 'us-west-2')
      endpoint = sns.create_platform_endpoint(
        platform_application_arn: ENV["SNS_APP_ARN"],
        token: self.token)
      self.update(endpoint_arn: endpoint[:endpoint_arn])
			return true
		rescue
			return false
		end
	end
end
