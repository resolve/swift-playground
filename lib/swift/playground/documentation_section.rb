require 'erb'

module Swift
  class Playground
    class DocumentationSection < Section
      extension 'html'
      directory 'Documentation'

      xcplayground node: 'documentation',
         path_attribute: 'relative-path'
    end
  end
end
