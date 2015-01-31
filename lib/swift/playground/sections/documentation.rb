require 'erb'

module Swift
  class Playground
    module Sections
      class Documentation < Section
        extension 'html'
        directory 'Documentation'

        xcplayground node: 'documentation',
           path_attribute: 'relative-path'
      end
    end
  end
end
