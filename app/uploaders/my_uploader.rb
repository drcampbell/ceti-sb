require 'aws-sdk'
class MyUploader
	def upload(path)
		s3 = Aws::S3::Resource.new(region: ENV["AWS-REGION"])
		obj = s3.bucket(ENV['S3-BUCKET']).object('key')
		obj.upload_file(path)
	end

end
