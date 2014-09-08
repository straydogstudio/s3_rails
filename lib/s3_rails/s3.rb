module S3Rails
  S3Template = Struct.new(:key, :read, :last_modified, :obj)

  class S3
    attr_accessor :access_key_id, :secret_access_key, :region, :bucket_name, :bucket, :s3, :objects, :last_load

    def initialize(config_file)
      puts Dir.pwd
      config = YAML::load(IO.read(config_file))
      @access_key_id = config['s3_rails']['access_key_id']
      @secret_access_key = config['s3_rails']['secret_access_key']
      @bucket_name = config['s3_rails']['bucket']
      @region = config['s3_rails']['region']
      @last_load = nil

      AWS.config(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)

      @s3 = AWS::S3.new
      unless @s3.buckets[ @bucket_name ].nil?
        @bucket = @s3.buckets[ @bucket_name ]
      end

      load_cache
    end

    def buckets
      @s3.buckets
    end

    def load_cache
      @objects = Hash[@bucket.objects.map {|o| [
          o.key,
          S3Template.new(o.key, o.read, o.last_modified, o)
        ]}]
      @last_load = Time.now
    end
  end
end
