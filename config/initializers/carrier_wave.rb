if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
        # Configuration for Amazon S3
        provider: 'AWS', 
        aws_access_key_id:      ENV['AWS_ACCESS_KEY'],
        aws_secret_access_key:  ENV['AWS_SECRET_KEY'],
        region:             ENV['AWS_REGION']
        #:host                   => ,
        #:endpoint:key => "value" 
    }
    config.fog_directory = ENV['S3_BUCKET']
    config.fog_public = false
    
  end
end

# if Rails.env.production?
#   CarrierWave.configure do |config|
#   	config.fog_provider = 'fog/aws'
#     config.fog_credentials = {
#         # Configuration for Amazon S3
#         :provider              => 'AWS',
#         :aws_access_key_id     => ENV['S3_ACCESS_KEY'],
#         :aws_secret_access_key => ENV['S3_SECRET_KEY'],
#         :region								 => 'us-west-1'
#         #:host									 => ,
#         #:endpoint:key => "value" 
#     }
#     config.fog_directory     = ENV['S3_BUCKET']
#     config.fog_public				 = false
#   end
# end