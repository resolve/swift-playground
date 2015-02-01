require 'fileutils'

require 'swift/playground/metadata'
require 'swift/playground/debug'
require 'swift/playground/generator'
require 'swift/playground/section'

module Swift
  class Playground
    class TemplateContext
      extend Forwardable

      def_delegators :@playground, :sdk, :allows_reset?, :sections

      def initialize(playground)
        @playground = playground
      end

      def context
        binding
      end
    end

    attr_accessor :platform, :allow_reset
    attr_accessor :sections

    class << self
      protected

      def template_path(filename)
        template_root = Pathname.new('../playground/template').expand_path(__FILE__)
        template_root.join(filename)
      end

      def xcplayground_template
        unless defined? @template
          template_path = template_path('contents.xcplayground.erb')
          @template = ERB.new(template_path.read)
        end

        @template
      end
    end

    def initialize(options = {})
      options = {
        platform: 'ios',
        allow_reset: true
      }.merge(options)

      self.sections = []
      self.platform = options[:platform]
      self.allow_reset = options[:allow_reset]
    end

    def platform=(platform)
      platform = platform.downcase
      raise 'Platform must be ios or osx' unless %w(ios osx).include?(platform)
      @platform = platform
    end

    def sdk
      case platform.to_s
      when 'ios'
        'iphonesimulator'
      when 'osx'
        'macosx'
      end
    end

    def allows_reset?
      allow_reset == true
    end

    def save(destination_path)
      validate!

      destination_path = Pathname.new(destination_path).expand_path

      # Create playground in a temporary directory before moving in place of
      # any existing playground. This avoids any partially written playground
      # files being re-loaded by Xcode:
      temp_path = Pathname.new(Dir.mktmpdir)
      write_stylesheet(temp_path)
      write_sections(temp_path)
      write_xcplayground(temp_path)

      FileUtils.rm_rf(destination_path) if destination_path.exist?
      FileUtils.mv(temp_path, destination_path)
    ensure
      FileUtils.remove_entry_secure(temp_path) if temp_path && temp_path.exist?
    end

    private

    def validate!
      unless sections.detect { |section| section.is_a?(CodeSection) }
        raise "A playground must have at least one code section."
      end
    end

    def write_stylesheet(temp_path)
      stylesheet_path = temp_path.join('Documentation', 'defaults.css')
      FileUtils.mkdir_p stylesheet_path.dirname

      stylesheet_template = template_path('Documentation/defaults.css')
      FileUtils.cp stylesheet_template, stylesheet_path
    end

    def write_sections(temp_path)
      sections.each_with_index do |section, index|
        number = index + 1
        path = temp_path.join(section.path number)
        FileUtils.mkdir_p path.dirname

        path.open('w') do |file|
          file.write section.render(number)
        end
      end
    end

    def write_xcplayground(temp_path)
      temp_path.join('contents.xcplayground').open('w') do |file|
        context = TemplateContext.new(self).context
        file.write xcplayground_template.result(context)
      end
    end

    def template_path(filename)
      self.class.send(:template_path, filename)
    end

    def xcplayground_template
      self.class.send(:xcplayground_template)
    end
  end
end
