module Swift::Playground::CLI
  module Global
    module ErrorHandling
      extend Definition

      definition do
        on_error do |exception|
          case exception
          when Interrupt
            UI.error
            UI.error("Execution interrupted.")
          when SystemExit
            # An intentional early exit has occurred and all relevant messages
            # have already been displayed, so do nothing
          else
            # We only want to display details of the exception under debug if it
            # is not a GLI exception (as a GLI exception relates to parsing
            # errors - e.g. wrong command, that we do not need to expand upon):
            debug_exception = (exception.class.to_s !~ /\AGLI/) ? exception : nil

            if exception.message
              UI.error("Execution failed: #{exception.message}", debug_exception)
            else
              UI.error("Execution failed.", debug_exception)
            end
          end

          false # Prevent default GLI error handling
        end

      end
    end
  end
end
