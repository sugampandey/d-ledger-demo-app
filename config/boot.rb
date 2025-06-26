ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Monkey-patch BigDecimal.new for Ruby >= 2.7 compatibility
if RUBY_VERSION >= "2.7.0"
  require 'bigdecimal'
  class BigDecimal
    def self.new(*args)
      BigDecimal(*args)
    end
  end
end