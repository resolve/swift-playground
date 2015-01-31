require 'active_support/concern'

# This class makes it possible to provide helper methods in a module that will
# be included inside the main Swift::Playground::CLI module.
#
# It's unfortunately a little magical, but its difficult to work around this
# due to the way the GLI dsl is not designed to use anywhere except at the top
# level (or at best, inside a module) and not in a class.
module Swift::Playground::CLI
  module Definition
    # Include ActiveSupport::Concern methods, so this module behaves like
    # ActiveSupport::Concern for any other module or class that extends it:
    include ActiveSupport::Concern

    def self.extended(mod)
      # Use the behaviour of the ActiveSupport::Concern modules `self.extended`
      # implementation:
      ActiveSupport::Concern.extended(mod)
    end

    def definition(&block)
      self.included do
        # The use of `extend(self)` here makes sure that a module that extends
        # the Definition module will have access to its methods from within
        # the GLI command actions it defines. It will define these commands
        # inside the block it passes to its call of the `definition` method.
        extend(self)
        self.class_eval(&block)
      end
    end
  end
end
