require 'html/pipeline'
require 'active_support/core_ext/object/deep_dup'

require_relative 'syntax_highlighting'
require_relative 'pipeline/section_filter'
require_relative 'pipeline/unicode_emoji_filter'

module Swift::Playground::Util
  module Pipeline
    HTMLWhitelist = HTML::Pipeline::SanitizationFilter::WHITELIST.deep_dup.tap do |whitelist|
      # Allow <section> elements to have a 'role' attribute (which we use to
      # distinguish between sections):
      whitelist[:elements] << 'section'
      whitelist[:attributes]['section'] = ['role']
    end

    FilterChain = [
      HTML::Pipeline::MarkdownFilter,

      # Filter for splitting out resulting HTML into separate HTML and swift
      # <section> elements, with appropriate metadata attached:
      SectionFilter,

      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::ImageMaxWidthFilter,
      HTML::Pipeline::MentionFilter,

      # Custom Emoji filter than replaces with unicode characters rather than
      # images (because a Swift Playground will always be opened on OS X which
      # supports rendering the unicode version natively):
      UnicodeEmojiFilter,

      # Only do syntax highlighting if the required gems are installed:
      (HTML::Pipeline::SyntaxHighlightFilter if SyntaxHighlighting.available?)
    ].compact

    def self.call(html, context = {}, result = nil)
      context = {
        gfm: true, # Enable support for GitHub formatted Markdown
        whitelist: HTMLWhitelist # Control HTML elements that are sanitized
      }

      HTML::Pipeline.new(FilterChain, context).call(html, context, result)
    end
  end
end
