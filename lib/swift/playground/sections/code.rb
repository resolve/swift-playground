require 'erb'

module Swift
  class Playground
    module Sections
      class Code < Section
        extension 'swift'
        directory false

        xcplayground node: 'code',
           path_attribute: 'source-file-name'

        attr_accessor :style

        def xcplayground_node(number)
          node = super(number)
          node['style'] = 'setup' if style == 'setup'
          node
        end
      end
    end
  end
end
