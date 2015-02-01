source 'https://rubygems.org'

gemspec

gem 'rake'

group :development do
  # github-linguist requires charlock_holmes which is not an easy install, making
  # this an optional dependency gives gem users the choice of whether to solve
  # the problem of installing that gem in order to get syntax highlighting.
  #
  # pygments.rb can also be problematic on some platforms and also is used
  # only for syntax highlighting so can be optional also:
  gem 'github-linguist', '~> 3.4.1'
  gem 'pygments.rb', '~> 0.6.0'

  gem 'pry'
  gem 'pry-byebug', '1.3.3'
end
