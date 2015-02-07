require 'pathname'

module Swift
  class Playground
    sections_path = Pathname.new('swift/playground/sections')
    autoload :DocumentationSection, sections_path.join('documentation_section')
    autoload :CodeSection,          sections_path.join('code_section')

    class Section
      include Util::PathOrContent

      class TemplateContext
        attr_accessor :content, :number

        extend Forwardable
        def_delegators :@playground, :stylesheets, :javascripts

        def self.context(*args)
          new(*args).instance_eval { binding }
        end

        def context
          binding
        end

        def initialize(content, number, playground)
          @content = content
          @number = number
          @playground = playground
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
              template_contents = '<%= content %>'
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
        self.content = path_or_content_as_io(content).read
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

      def render(number, playground, custom_content = nil)
        context = TemplateContext.context custom_content || content,
                                          number,
                                          playground
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
