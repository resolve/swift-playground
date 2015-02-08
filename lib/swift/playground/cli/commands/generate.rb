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
                   desc: 'CSS stylesheet for the HTML documentation sections of the playground. This will be included after the default stylesheet.'

          c.flag   :javascript,
                   arg_name: '<file>',
                   type: String,
                   desc: 'A javascript file for the HTML documentation sections of the playground. Each section is rendered independently of another and the script will not have access to the DOM from any other sections.'

          c.switch :emoji,
                   default_value: true,
                   desc: "Convert emoji aliases (e.g. ':+1:') into emoji characters."

          c.switch :highlighting,
                   default_value: true,
                   desc: "Detect non-swift code blocks and add syntax highlighting. Only has an effect if 'github-linguist' and 'pygments.rb' gems are installed."

          c.flag   :'highlighting-style',
                   arg_name: '<style>',
                   type: 'String',
                   default_value: 'default',
                   desc: "The name of a pygments (http://pygments.org/) style to apply to syntax highlighted code blocks. Set to 'custom' if providing your own pygments-compatible stylesheet. Ignored if --no-highlighting is set."

          # c.flag   :resources,
          #          arg_name: '<directory>',
          #          type: String,
          #          desc: 'A directory of resources to be bundled with the playground.'

          c.action do |_, options, args|
            markdown_file = Pathname.new(args[0]).expand_path
            if args[1]
              playground_file = Pathname.new(args[1]).expand_path
            else
              playground_file = markdown_file.sub_ext('.playground')
            end

            playground = Swift::Playground::Generator.generate(markdown_file)
            playground.platform = options['platform']
            playground.allow_reset = options['reset']
            playground.convert_emoji = options['emoji']

            if options['highlighting']
              playground.syntax_highlighting = options['highlighting-style']
            else
              playground.syntax_highlighting = false
            end

            if options['stylesheet']
              stylesheet_path = Pathname.new(options['stylesheet']).expand_path

              unless stylesheet_path.exist?
                raise "Stylesheet file does not exist: '#{stylesheet_path}'."
              end

              stylesheet = Swift::Playground::Stylesheet.new(stylesheet_path)
              playground.stylesheets << stylesheet
            end

            if options['javascript']
              javascript_path = Pathname.new(options['javascript']).expand_path

              unless javascript_path.exist?
                raise "Javascript file does not exist: '#{javascript_path}'."
              end

              javascript = Swift::Playground::Javascript.new(javascript_path)
              playground.javascripts << javascript
            end

            playground.save(playground_file)

            UI.say "Created playground at #{playground_file}"

            if options['open']
              system('open', playground_file.to_s)
            end
          end
        end
      end
    end
  end
end
