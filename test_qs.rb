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

require 'spec/runner/formatter/profile_formatter'



class Array
  def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
  end
  def mean
    sum / size.to_f
  end
  def variance
    avg = mean # calculate once
    sum_avg = inject(0) do |acc,i|
      acc+((i-avg)**2)
    end
    (sum_avg / size.to_f)
  end
  def std_dev
    Math.sqrt(variance)
  end
end

# patch the profile formatter to return all of the formatts
module Spec
    module Runner
      module Formatter
        class RobustProfileFormatter <  ProfileFormatter

          def start_dump
             
             
             @example_times = @example_times.sort_by do |description, example, time|
               time
             end.reverse

             times = @example_times.map {|d,e,t| t}
             mean = times.mean
             stddev = times.std_dev
             #k = 0
             #@example_times.reject! { |d,e,t| t < mean + k * stddev }

             @output.puts "\n\n#{@example_times.size} profiled examples:\n"

               @example_times.each do |description, example, time|
               @output.print red(sprintf("%.7f", time))
               @output.puts "\t#{description} #{example}"
             end

             @output.puts "\n\nStats"

             @output.puts "Mean:\t#{"%.5f" % mean}"
             @output.puts "StdDev:\t#{"%.5f" % stddev}"
             @output.puts "Total:\t#{times.size}"
             @output.puts "Slow:\t#{@example_times.size}"

             @output.flush
           end
        end
      end
    end
end

module Spec
  module QSTest
    class Runner
      def self.run(lang,format)
        argv = Array.new()
        argv << "query_server_spec.rb"
        argv << "--require"
        argv << "./#{lang}-test.rb"
        argv << '--format'
        if format == 'profile' then 
          argv << 'Spec::Runner::Formatter::RobustProfileFormatter'
        else
          argv << format
        end
        argv << '--color'
        ::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(argv,STDERR,STDOUT))
      end
    end
  end
end



Spec::QSTest::Runner.run(lang,format)
