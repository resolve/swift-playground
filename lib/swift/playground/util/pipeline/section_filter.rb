require 'html/pipeline'

module Swift::Playground::Util
  class Pipeline
    class SectionFilter < HTML::Pipeline::Filter
      def call
        # Solution derived from http://stackoverflow.com/a/4799902
        children = doc.children # Every immediate child of the doc
        doc.inner_html = ''     # Empty the doc now that we have our nodes

        # Comments preceding a swift code section can have meaning, so we need
        # to track the last comment made:
        last_comment = nil
        section = new_section(doc) # Create our first container in the doc
        children.each do |node|
          if node.name == 'comment'
            last_comment = node.content.strip
          elsif node.name == 'pre' && node[:lang] == 'swift' && last_comment != 'IGNORE'
            # If this code is the first thing in the document then the previous
            # section will be empty and the only child of the document, so we
            # should remove it:
            section.remove if section.content.empty? && doc.children.count == 1

            swift_section = new_section(doc, role: 'code')
            swift_section[:title] = last_comment unless last_comment.blank?
            node.remove_attribute('lang')
            swift_section << node

            section = new_section(doc) # Create a new container for subsequent nodes
          else
            last_comment = nil unless node.name == 'text' && node.content.blank?
            section << node
          end
        end
        section.remove if section.content.empty?  # Get rid of a trailing, empty section

        doc
      end

      private

      def new_section(doc, attributes = {})
        attributes = {
          role: 'documentation'
        }.merge(attributes)

        section = (doc << '<section>').children.last
        attributes.each do |attribute, value|
          section[attribute] = value
        end
        section
      end
    end
  end
end
