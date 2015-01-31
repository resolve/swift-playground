require 'gli'
require_relative 'cli/definition'
require_relative 'cli/shared_attributes'
require_relative 'cli/ui'
require_relative 'cli/commands/new'
require_relative 'cli/commands/generate'
require_relative 'cli/global/error_handling'

require_relative 'generator'

module Swift
  class Playground
    module CLI
      extend GLI::App

      program_desc SUMMARY
      version      VERSION

      subcommand_option_handling :normal
      arguments :strict
      sort_help :manually

      include Commands::Generate
      include Commands::New

      include Global::ErrorHandling
    end
  end
end
