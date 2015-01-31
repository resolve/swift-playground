require 'highline/import'
require 'paint'
require 'forwardable'
require 'active_support/core_ext/module'

unless STDOUT.tty?
  # If we aren't using a TTY, then we need to avoid Highline attempting to set
  # TTY specific features (such as 'no echo mode'), as these will fail. We can
  # do so by monkey patching Highline to make the methods that peform these
  # functions no-ops:
  class HighLine
    module SystemExtensions
      def raw_no_echo_mode
      end

      def restore_mode
      end
    end
  end
end

Paint::SHORTCUTS[:swift_playground] = {
  :red => Paint.color(:red),
  :blue => Paint.color(:blue),
  :cyan => Paint.color(:cyan),
  :bright => Paint.color(:bright)
}
$paint = Paint::SwiftPlayground

# Convenience module for accessing Highline features
module Swift::Playground::CLI
  module UI
    extend SingleForwardable

    mattr_accessor :show_debug, :color_mode, :silence

    def_delegators :$terminal, :agree, :ask, :choose
    def_delegators :$paint, *Paint::SHORTCUTS[:swift_playground].keys

    class << self
      def say(message = "\n")
        return if silence

        terminal.say message
      end

      def error(message = nil, exception = nil)
        return if silence

        stderr.puts red(message)
        if exception && show_debug
          exception_details = ["Handled <#{exception.class}>:",
                               exception.message,
                               *exception.backtrace]
          stderr.puts red("\n" + exception_details.join("\n") + "\n")
        end
      end

      def debug(message = nil, &block)
        return if silence

        if show_debug
          message = formatted_log_message(message, &block)
          stderr.puts blue(message)
        end
      end

      def info(message = nil, &block)
        return if silence

        if show_debug
          message = formatted_log_message(message, &block)
          stderr.puts cyan(message)
        end
      end

      private

      def formatted_log_message(message = nil, &block)
        if block
          lines = block.call.split("\n")
          if message
            message = "#{message}: "
            message += "\n  " if lines.count > 1
            message += lines.join("\n  ")
          else
            message += lines.join("\n")
          end
        end

        message
      end

      def colorize(stream)
        case (color_mode || 'auto')
        when 'auto'
          if stream.tty?
            Paint.mode = Paint.detect_mode
          else
            Paint.mode = 0
          end
        when 'always'
          Paint.mode = Paint.detect_mode
        when 'never'
          Paint.mode = 0
        end
      end

      def terminal
        colorize($stdout)
        $terminal
      end

      def stderr
        colorize($stderr)
        $stderr
      end
    end
  end
end
