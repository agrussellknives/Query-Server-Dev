#!/usr/bin/env ruby

COUCH_ROOT = ENV['COUCH_ROOT'] || '/usr/bin'

unless File.exists?("#{COUCH_ROOT}/couchdb")
  puts "Couldn't find couchdb executable at #{COUCH_ROOT}/couchdb."
  puts 'You need to set your COUCH_ROOT enviroment variable'
  exit 1
end


format = ARGV.pop
lang = ARGV.pop

require 'spec'
require 'spec/autorun'
require 'ruby-debug'

module Spec
  module QSTest
    class Runner
      def self.run(lang,format)
        argv = Array.new()
        argv << "query_server_spec.rb"
        argv << "--require"
        argv << "#{lang}-test.rb"
        argv << '--format'
        argv << format
        argv << '--color'
        ::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(argv,STDERR,STDOUT))
      end
    end
  end
end

Spec::QSTest::Runner.run(lang,format)