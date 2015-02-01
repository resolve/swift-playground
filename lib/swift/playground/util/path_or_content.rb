require 'pathname'

module Swift::Playground::Util
  module PathOrContent
    def path_or_content_as_io(path_or_content)
      # Return path_or_content if it is an IO-like object
      return path_or_content if path_or_content.respond_to?(:read)

      unless path_or_content.is_a?(String)
        raise "You must provide either a String or an IO object when constructing a #{self.class.name}."
      end

      if path_or_content !~ /[^\n]/ && !path_or_content.blank?
        path = Pathname.new(path_or_content).expand_path
        return path if path.exist?

        raise "Path '#{path}' not found. Please add a newline to any raw content."
      else
        StringIO.new(path_or_content)
      end
    end
  end
end
