require 'active_support/core_ext/string/strip'

module Swift::Playground::CLI
  module Commands
    module New
      extend Definition

      definition do
        desc 'Create an empty playground (just as Xcode would via "File > New > Playground...")'
        arg '<playground_file>'
        command :new do |c|
          c.extend SharedCreationSwitches

          c.action do |_, options, args|
            playground_file = Pathname.new(args[0]).expand_path

            playground = Swift::Playground.new(platform: options[:platform])

            case options[:platform]
            when 'ios'
              contents = <<-IOS.strip_heredoc
                // Playground - noun: a place where people can play

                import UIKit

                var str = "Hello, playground"
              IOS
            when 'osx'
              contents = <<-OSX.strip_heredoc
                // Playground - noun: a place where people can play

                import Cocoa

                var str = "Hello, playground"
              OSX
            end

            playground.sections << Swift::Playground::CodeSection.new(contents)
            playground.save(playground_file)

            if options['open']
              system('open', playground_file.to_s)
            end
          end
        end
      end
    end
  end
end
