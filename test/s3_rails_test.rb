require 'test_helper'

class S3RailsTest < ActiveSupport::TestCase
  def setup
    # @resolver = S3Resolver.instance
    # @s3rails = @resolver.s3rails
    @s3rails = S3Rails::S3.new('test/dummy/config/s3_rails.yml')
  end

  test "connects to S3" do
    assert_equal 'app-widgets', @s3rails.bucket_name, 'bucket_name'
    bucket_size = 0
    @s3rails.bucket.objects.each {|o| bucket_size+= 1}
    assert_equal 9, bucket_size, 'bucket_size'
  end
end
