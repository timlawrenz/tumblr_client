module Tumblr
  module Helper
    private

    def blog_path(blog_name, ext)
      "v2/blog/#{full_blog_name(blog_name)}/#{ext}"
    end

    def full_blog_name(blog_name)
      blog_name.include?('.') ? blog_name : "#{blog_name}.tumblr.com"
    end

    def validate_options(valid_opts, opts)
      bad_opts = opts.reject { |val| valid_opts.include?(val) }
      return unless bad_opts.any?

      raise ArgumentError,
            "Invalid options (#{bad_opts.keys.join(', ')}) passed, only #{valid_opts} allowed."
    end

    def validate_no_collision(options, attributes)
      count = attributes.count { |attr| options.key?(attr) }
      return unless count > 1

      raise ArgumentError,
            "Can only use one of: #{attributes.join(', ')} (Found #{count})"
    end
  end
end
