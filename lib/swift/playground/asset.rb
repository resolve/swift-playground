module Swift
  class Playground
    assets_path = Pathname.new('swift/playground/assets')
    autoload :Stylesheet, assets_path.join('stylesheet')

    class Asset
      include Util::PathOrContent

      class << self
        protected

        def default_filename(filename = nil)
          @default_filename = filename unless filename.nil?
          @default_filename
        end
      end

      attr_accessor :content

      def initialize(content, options = {})
        pathname_or_content = path_or_content_as_io(content)
        self.content = pathname_or_content.read

        filename = options[:filename] || derived_filename(pathname_or_content)
        @filename = filename || default_filename
      end

      def filename(number)
        @filename % number
      end

      def save(destination_path, number)
        destination_path = Pathname.new(destination_path)

        expanded_filename = filename(number)
        path = destination_path.join(expanded_filename)

        FileUtils.mkdir_p path.dirname
        path.open('w') do |file|
          file.write content
        end
      end

      protected

      def default_filename
        self.class.send(:default_filename)
      end

      def derived_filename(pathname_or_content)
        if pathname_or_content.respond_to?(:basename)
          pathname_or_content.basename.to_s
        end
      end
    end
  end
end
