require 'bundler/setup'
Bundler.setup

require 'live_paper' # and any other gems you need

# include helpers
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'spec_helpers', '**', '*.rb'))].each { |f| require f }

RSpec.configure do |config|
  # some (optional) config here
end

