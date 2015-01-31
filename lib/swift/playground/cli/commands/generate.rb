module Swift::Playground::CLI
  module Commands
    module Generate
      extend Definition

      definition do
        desc 'Generate a playground file from the provided Markdown file'
        arg '<markdown_file>'
        arg '<playground_file>', :optional
        command :generate do |c|
          c.extend SharedCreationSwitches

          c.flag   :stylesheet,
                   arg_name: '<file>',
                   type: String,
                   desc: 'CSS stylesheet for the HTML documentation sections of the playground. If one is not supplied then a default stylesheet will be used'

          c.flag   :javascript,
                   arg_name: '<file>',
                   type: String,
                   desc: 'A javascript file for the HTML documentation sections of the playground. Each section is rendered independently of another and the script will not have access to the DOM from any other sections'

          c.switch :emoji,
                   default_value: true,
                   desc: "Convert emoji aliases (e.g. ':+1:') into emoji characters"

          c.flag   :resources,
                   arg_name: '<directory>',
                   type: String,
                   desc: 'A directory of resources to be bundled with the playground'

          c.action do |_, options, args|
            markdown_file = Pathname.new(args[0]).expand_path
            if args[1]
              playground_file = Pathname.new(args[1]).expand_path
            else
              playground_file = markdown_file.sub_ext('.playground')
            end

            playground = Swift::Playground::Generator.generate(markdown_file)
            playground.platform = options[:platform]
            playground.allow_reset = options[:reset]
            playground.save(playground_file)

            UI.say "Created playground at #{playground_file}"
          end
        end
      end
    end
  end
end
