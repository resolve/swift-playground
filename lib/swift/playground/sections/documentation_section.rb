module Swift
  class Playground
    class DocumentationSection < Section
      extension 'html'
      directory 'Documentation'

      xcplayground node: 'documentation',
         path_attribute: 'relative-path'

      def content=(content)
        raise 'Please provide an HTML fragment only' if content =~ /(<html>|<body>)/
        super(content)
      end

      def render(number, playground)
        save_content

        pipeline = Util::Pipeline.new
        if playground.convert_emoji?
          pipeline.filters << Util::Pipeline::EmojiFilter
        end

        if playground.syntax_highlighting
          if Util::SyntaxHighlighting.available?
            pipeline.filters << HTML::Pipeline::SyntaxHighlightFilter
          else
            $stderr.puts "WARNING: Unable to highlight syntax for section " +
                         "#{number}, please make sure that github-linguist " +
                         "and pygments.rb gems are installed."
          end
        end

        if pipeline.has_filters?
          processed = pipeline.call(content)
          self.content = processed[:output].inner_html
        end

        rendered = super(number, playground)
        restore_content

        rendered
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
