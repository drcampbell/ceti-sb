class MyUploader
	def upload(file)
	  s3 = Aws::S3::Resource.new(:region => "us-west-1")
	  s3Bucket = s3.bucket("ceti-sb")
	  obj = s3Bucket.object(file)
    obj.upload_file("public/" + file, {acl: "public-read"})
    
    #obj.upload_file("public/badges/Go.png" , {acl: "public-read"})
    
	  s3BucketAcl = s3Bucket.acl
	  s3BucketAcl.put({acl: "public-read"})
   

	end

end
