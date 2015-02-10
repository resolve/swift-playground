require 'pathname'

module Swift::Playground::Util
  module SourceIO
    def source_as_io(source)
      # Return path_or_content if it is an IO-like object
      return source if source.respond_to?(:read)

      unless source.is_a?(String)
        raise "You must provide either a String or an IO object when constructing a #{self.class.name}."
      end

      StringIO.new(source)
    end

    def derived_filename(source)
      if source.respond_to?(:basename)
        source.basename.to_s
      elsif source.respond_to?(:path)
        File.basename(source.path)
      end
    end
  end
end
