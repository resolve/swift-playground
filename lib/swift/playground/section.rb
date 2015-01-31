module Swift
  class Playground
    module Sections
      autoload :Documentation, 'swift/playground/sections/documentation'
      autoload :Code,          'swift/playground/sections/code'
    end

    class Section
      class TemplateContext
        attr_accessor :number

        def initialize(section, number)
          @section = section
          @number = number
        end

        def context
          binding
        end

        def filename
          @section.filename(@number)
        end

        def method_missing(method, *args)
          super unless @section.respond_to?(method)
          @section.send(method, *args)
        end

        def respond_to?(method)
          @section.respond_to?(method) || super
        end
      end

      attr_accessor :content

      class << self
        protected

        def template
          unless defined? @template
            template_root = Pathname.new('../template').expand_path(__FILE__)
            template_path = template_root.join(@directory, "section.#{@extension}.erb")

            if template_path.exist?
              template_contents = template_path.read
            else
              template_contents = "<%= content %>"
            end
            @template = ERB.new(template_contents)
          end

          @template
        end

        def extension(extension = nil)
          @extension = extension unless extension.nil?
          @extension
        end

        def directory(path = nil)
          @directory = Pathname.new(path || '') unless path.nil?
          @directory
        end

        def xcplayground(options = nil)
          @xcplayground_options = options unless options.nil?
          @xcplayground_options
        end
      end

      def initialize(content)
        @content = content
      end

      def filename(number)
        "section-#{number}.#{extension}"
      end

      def path(number)
        directory.join filename(number)
      end

      def xcplayground_node(number)
        options = xcplayground_options

        node = Nokogiri::XML.fragment("<#{options[:node]}>").children.first
        node[options[:path_attribute]] = path(number).relative_path_from(directory)
        node
      end

      def render(number)
        context = TemplateContext.new(self, number).context
        template.result(context)
      end

      protected

      def template
        self.class.send(:template)
      end

      def extension
        self.class.send(:extension)
      end

      def directory
        self.class.send(:directory)
      end

      def xcplayground_options
        self.class.send(:xcplayground)
      end
    end
  end
end
