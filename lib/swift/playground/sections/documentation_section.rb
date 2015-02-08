module Swift
  class Playground
    class DocumentationSection < Section
      extension 'html'
      directory 'Documentation'

      xcplayground node: 'documentation',
         path_attribute: 'relative-path'

      attr_reader :assets

      def initialize(content)
        super(content)

        if @content =~ /(<html|<head|<body)[\s>]/
          raise 'Please provide an HTML fragment only. ' +
                'Do not include an <html>, <head> or <body> tag.'
        end

        extract_assets
      end

      def render(number, playground)
        pipeline = Util::Pipeline.new
        if playground.convert_emoji?
          pipeline.filters << Util::Pipeline::EmojiFilter
        end

        if playground.syntax_highlighting
          if Util::SyntaxHighlighting.available?
            pipeline.filters << Util::Pipeline::SyntaxHighlightFilter
          else
            $stderr.puts "WARNING: Unable to highlight syntax for section " +
                         "#{number}, please make sure that github-linguist " +
                         "and pygments.rb gems are installed."
          end
        end

        if pipeline.has_filters?
          processed = pipeline.call(content)
          super(number, playground, processed[:output].inner_html)
        else
          super(number, playground)
        end
      end

      private

      def extract_assets
        @assets = []

        document = Nokogiri::HTML(@content)
        document.search('//img[@src]').each do |img|
          image_path = Pathname.new(img['src'])

          if image_path.relative?
            @assets << Asset.new(img['src'])
          end
        end
      end
    end
  end
end
