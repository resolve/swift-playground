module Swift::Playground::CLI
  module SharedCreationSwitches
    def self.extended(command)
      command.flag   :platform,
                     default_value: 'ios',
                     arg_name: '[ios|osx]',
                     must_match: %w{ios osx},
                     desc: 'The target platform for the generated playground.'

      command.switch :reset,
                     default_value: true,
                     desc: 'Allow the playground to be reset to it\'s original state via "Editor > Reset Playground" in Xcode.'

      command.switch :open,
                     negatable: false,
                     desc: 'Open the playground in Xcode once it has been created.'
    end
  end
end
