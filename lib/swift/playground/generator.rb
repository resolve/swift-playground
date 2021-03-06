require_relative 'util'

module Swift
  class Playground
    class Generator
      class << self
        include Util::SourceIO

        def generate(markdown, options={})
          markdown_file = source_as_io(markdown)

          playground = Playground.new

          pipeline = Util::Pipeline.new(Util::Pipeline::MarkdownFilterChain)
          converted_markdown = pipeline.call(markdown_file.read)[:output]
          converted_markdown.xpath('./section').each do |section|
            case section[:role]
            when 'documentation'
              html = section.inner_html
              playground.sections << DocumentationSection.new(html)
            when 'code'
              code = section.xpath('./pre/code').inner_text
              playground.sections << CodeSection.new(code)
            end
          end

          playground
        end
      end
    end
  end
end
