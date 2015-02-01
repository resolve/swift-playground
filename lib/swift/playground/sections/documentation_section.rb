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
    end
  end
end
