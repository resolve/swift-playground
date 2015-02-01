require 'html/pipeline'

module Swift::Playground::Util
  class Pipeline
    class UnicodeEmojiFilter < HTML::Pipeline::EmojiFilter

      def validate
        # No need to for :asset_root in context like EmojiFilter requires
      end

      # Override EmojiFilter's image replacement to replace with Unicode instead:
      def emoji_image_filter(text)
        text.gsub(emoji_pattern) do |match|
          name = $1
          "<span class='emoji'>#{emoji_unicode_replacement(name)}</span>"
        end
      end

      private

      def emoji_unicode_replacement(name)
        Emoji.find_by_alias(name).raw
      end

    end
  end
end
