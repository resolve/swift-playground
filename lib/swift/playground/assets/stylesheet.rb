require 'sass'

module Swift
  class Playground
    class Stylesheet < Asset
      default_filename 'stylesheet-%d.css'

      def save(destination_path, number)
        save_content

        self.content = Sass.compile(content)
        super(destination_path, number)

        restore_content
      end

      protected

      def derived_filename(pathname_or_content)
        filename = super(pathname_or_content)
        filename.gsub(/\.scss$/, '') if filename
      end

      private

      def save_content
        @saved_content = content
      end

      def restore_content
        self.content = @saved_content
        @saved_content = nil
      end
    end
  end
end
