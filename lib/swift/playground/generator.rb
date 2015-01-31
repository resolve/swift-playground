require_relative 'util'

module Swift
  class Playground
    class Generator
      class << self
        def generate(markdown_file)
          markdown_file = Pathname.new(markdown_file)

          playground = Playground.new

          converted_markdown = Util::Pipeline.call(markdown_file.read)[:output]
          converted_markdown.xpath('./section').each do |section|
            case section[:role]
            when 'documentation'
              html = section.inner_html
              playground.sections << DocumentationSection.new(html)
            when 'code'
              code = section.xpath('./pre/code').inner_html
              playground.sections << CodeSection.new(code)
            end
          end

          playground
        end
      end
    end
  end
end
