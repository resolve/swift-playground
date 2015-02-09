module Bundler
  class GemHelper
    def perform_git_push_with_clean_env(options = '')
      # Using a clean ENV ensures that ruby-based git credential helpers
      # such as that used by boxen will still work:
      Bundler.with_clean_env do
        perform_git_push_without_clean_env(options)
      end
    end

    alias_method :perform_git_push_without_clean_env, :perform_git_push
    alias_method :perform_git_push, :perform_git_push_with_clean_env
  end
end

require 'bundler/gem_tasks'
