require 'test_helper'

class S3RailsTest < ActiveSupport::TestCase
  def setup
    @resolver = S3Rails::Resolver.instance
    @s3rails = @resolver.s3
  end

  test "connects to S3" do
    assert_equal 'app-widgets', @s3rails.bucket_name, 'bucket_name'
    bucket_size = 0
    @s3rails.bucket.objects.each {|o| bucket_size+= 1}
    assert_equal 9, bucket_size, 'bucket_size'
  end

  test "resolver returns a template body" do
    details = {
      locale:[],
      formats:[:html],
      variants:[],
      handlers:[:erb]
    }

    template = @resolver.find_all("index", "widgets", false, details).first
    assert_kind_of ActionView::Template, template, 'ActionView::Template'

    assert_equal 's3/app-widgets/widgets/index.html.erb', template.identifier, 'identifier'
    assert_kind_of ActionView::Template::Handlers::ERB, template.handler, 'handler'
    assert_equal 'widgets/index', template.virtual_path, 'virtual_path'
    assert_equal [:html], template.formats, 'formats'
    assert_equal [nil], template.variants
    assert_equal 1406666054, template.updated_at.to_i
  end

  test "reload S3rails cache" do
    # last load time
    last_load = @s3rails.last_load

    # find widgets/index
    details = {locale:[], formats:[:html], variants:[], handlers:[:erb]}
    template = @resolver.find_all("index", "widgets", false, details).first
    assert_match "<h1>Listing widgets</h1>", template.source

    # simulate template change by changing bucktes
    first_objects = @s3rails.objects
    @s3rails.bucket = @s3rails.buckets['app-widgets2']
    require 'fileutils'
    FileUtils.touch 'tmp/reload_s3.txt', mtime: Time.now + 1.seconds

    # find widgets/index again
    template = @resolver.find_all("index", "widgets", false, details).first
    assert_match "<h1>Listing widgets 2</h1>", template.source

    # different?
    assert_not_equal last_load, @s3rails.last_load

    # reset to original conditions
    @s3rails.bucket = @s3rails.buckets['app-widgets']
    @s3rails.objects = first_objects
  end
end
