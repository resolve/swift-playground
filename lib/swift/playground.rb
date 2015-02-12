require 'fileutils'
require 'tmpdir'

require 'swift/playground/metadata'
require 'swift/playground/debug'
require 'swift/playground/generator'
require 'swift/playground/section'
require 'swift/playground/asset'

module Swift
  class Playground
    class TemplateContext
      extend Forwardable
      def_delegators :@playground, :sdk, :allows_reset?, :sections

      def self.context(*args)
        new(*args).instance_eval { binding }
      end

      def initialize(playground)
        @playground = playground
      end
    end

    attr_accessor :platform, :allow_reset, :convert_emoji, :syntax_highlighting
    attr_accessor :sections, :stylesheets, :javascripts

    class << self
      protected

      def template_path(*filenames)
        template_root = Pathname.new('../playground/template').expand_path(__FILE__)
        template_root.join(*filenames)
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
      self.sections = []
      self.stylesheets = []
      self.javascripts = []

      stylesheet_path = template_path 'Documentation', 'defaults.css.scss'
      self.stylesheets << Stylesheet.new(stylesheet_path)

      options = {
        platform: 'ios',
        allow_reset: true,
        convert_emoji: true,
        syntax_highlighting: true
      }.merge(options)

      self.platform = options[:platform]
      self.allow_reset = options[:allow_reset]
      self.convert_emoji = options[:convert_emoji]
      self.syntax_highlighting = options[:syntax_highlighting]
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

    def convert_emoji?
      convert_emoji == true
    end

    def save(destination_path)
      destination_path = Pathname.new(destination_path).expand_path

      validate! destination_path

      insert_highlighting_stylesheet

      # Create playground in a temporary directory before moving in place of
      # any existing playground. This avoids any partially written playground
      # files being re-loaded by Xcode:
      temp_path = Pathname.new(Dir.mktmpdir)
      write_stylesheets(temp_path)
      write_javascripts(temp_path)
      write_sections(temp_path)
      write_xcplayground(temp_path)

      FileUtils.rm_rf(destination_path) if destination_path.exist?
      FileUtils.mv(temp_path, destination_path)
    ensure
      remove_highlighting_stylesheet
      FileUtils.remove_entry_secure(temp_path) if temp_path && temp_path.exist?
    end

    private

    def validate!(destination_path)
      unless destination_path.extname == '.playground'
        raise "Destination path '#{destination_path} does not end in .playground."
      end

      unless sections.detect { |section| section.is_a?(CodeSection) }
        raise 'A playground must have at least one code section.'
      end
    end

    def insert_highlighting_stylesheet
      if syntax_highlighting && Util::SyntaxHighlighting.available?
        style = if syntax_highlighting == true
          'default'
        else
          syntax_highlighting
        end

        unless style == 'custom'
          @highlighting_css = Stylesheet.new(Util::SyntaxHighlighting.css(style),
                                             filename: 'highlighting.css')
          self.stylesheets.insert(0, @highlighting_css)
        end
      end
    end

    def remove_highlighting_stylesheet
      if @highlighting_css
        self.stylesheets.delete(@highlighting_css)
        @highlighting_css = nil
      end
    end

    def write_stylesheets(temp_path)
      stylesheets_path = temp_path.join('Documentation')

      stylesheets.each_with_index do |stylesheet, index|
        number = index + 1
        stylesheet.save(stylesheets_path, number)
      end
    end

    def write_javascripts(temp_path)
      javascripts_path = temp_path.join('Documentation')

      javascripts.each_with_index do |javascript, index|
        number = index + 1
        javascript.save(javascripts_path, number)
      end
    end

    def write_sections(temp_path)
      sections.each_with_index do |section, index|
        number = index + 1
        path = temp_path.join(section.path number)

        FileUtils.mkdir_p path.dirname
        path.open('w') do |file|
          file.write section.render(number, self)
        end
      end
    end

    def write_xcplayground(temp_path)
      temp_path.join('contents.xcplayground').open('w') do |file|
        context = TemplateContext.context(self)
        file.write xcplayground_template.result(context)
      end
    end

    def template_path(*filenames)
      self.class.send(:template_path, *filenames)
    end

    def xcplayground_template
      self.class.send(:xcplayground_template)
    end
  end
end
