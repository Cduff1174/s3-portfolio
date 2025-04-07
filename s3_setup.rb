require 'aws-sdk-s3'

bucket_name = "portfolio-site0-#{Time.now.to_i}" # must be unique
region = "us-east-1"
file_to_upload = "index.html"

# Initialize the S3 client
s3 = Aws::S3::Client.new(region: region)

# 1 Create the bucket
begin
    s3.create_bucket(bucket: bucket_name)
    puts "* Bucket '#{bucket_name}' created."
rescue Aws::S3::Errors::BucketAlreadyExists
    puts "X Bucket name already taken."
end

# 2 Enable static website hosting 
s3.put_bucket_website({
    bucket: bucket_name,
    website_configuration: {
        index_document: { suffix: "index.html"}
    }
})
puts "Static website hosting enabled."

# 3 Upload index.html
s3.put_object(
    bucket: bucket_name,
    key: "index.html",
    body: File.read(file_to_upload),
    content_type: "text/html"
)
puts "Uploaded index.html"

# 4 Set public-read bucket policy
policy = {
  "Version" => "2012-10-17",
  "Statement" => [
    {
      "Sid" => "PublicReadGetObject",
      "Effect" => "Allow",
      "Principal" => "*",
      "Action" => "s3:GetObject",
      "Resource" => "arn:aws:s3:::#{bucket_name}/*"
    }
  ]
}


s3.put_bucket_policy(bucket: bucket_name, policy: policy.to_json)
puts " Public read access granted"

# 5 Output static website endpoint
puts "Your website is live at:"
puts "http://#{bucket_name}.s3-website-#{region}.amazonaws.com"