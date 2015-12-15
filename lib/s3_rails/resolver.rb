module S3Rails
  class Resolver < ActionView::PathResolver
    include Singleton
    attr_accessor :s3

    def initialize()
      super
      @s3 = S3Rails::S3.new('config/s3_rails.yml')
    end

    def build_query(path, details)
      exts = EXTENSIONS.map do |ext, prefix|
        "{" +
        details[ext].compact.uniq.map { |e| "#{prefix}#{e}," }.join +
        "}"
      end.join

      path.to_s + exts
    end

    def query(path, details, formats)
      # TODO: this would be more efficient if implemented in S3Rails::S3::load_cache
      unless (@s3.include_list && @s3.include_list.include?(path.to_s))
        Rails.logger.debug("s3_rails: ignoring #{path} since absent from include_list #{@s3.include_list.inspect}")
        return nil
      end

      query = build_query(path, details)

      if File.exists?('tmp/reload_s3.txt') &&
          @s3.last_load < File.mtime('tmp/reload_s3.txt')
        reload
      end

      # objects = @s3.bucket.objects.with_prefix(path.prefix).select do |obj|
      #   File.fnmatch query, obj.key, File::FNM_EXTGLOB
      # end

      objects = @s3.objects.select do |key, obj|
        File.fnmatch query, key, File::FNM_EXTGLOB
      end

      objects.map do |key, obj|
        template = "s3/#{@s3.bucket_name}/#{obj.key}"
        handler, format, variant =
          extract_handler_and_format_and_variant(template, formats)
        contents = obj.read

        ActionView::Template.new(contents, template, handler,
          :virtual_path => path.virtual,
          :format       => format,
          :variant      => variant,
          :updated_at   => obj.last_modified
        )
      end
    end

    def reload
      @s3.load_cache
      clear_cache
    end
  end
end
