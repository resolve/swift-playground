begin
  require 'pygments'
rescue LoadError
  # Ignore a failure to load the pygments gem
end

module Swift
  class Playground
    module Util
      class SyntaxHighlighting
        class << self
          def available?
            Gem::Specification::find_all_by_name('github-linguist').any? &&
            Gem::Specification::find_all_by_name('pygments.rb').any?
          end

          def css(style = 'default')
            if available?
              Pygments.css('.highlight', style: style)
            else
              ''
            end
          end
        end
      end
    end
  end
end
