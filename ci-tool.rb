#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'rdoc/usage'
require 'pp'
require 'date'

require 'runner.rb'

@failure = "Command failed"
@success = "Command succeeded"
@command = ""
@directories = []

opts = OptionParser.new
opts.on('-d', '--directory DIR', 'The directory that you wish to watch') do |opt|
	  @directories << opt
end

opts.on('-c', '--command COMMAND', 'The command to run') do |opt|
	  @command = opt
end

opts.on('-f', '--failure FAILURE', 'The failure message') do |opt|
	  @failure = opt
end

opts.on('-s', '--success SUCCESS', 'The success message') do |opt|
	  @success = opt
end

opts.on_tail('-h', '--help', 'Display this message') do
	puts opts
	exit
end

opts.banner = "Usage: ci-tool.rb [options]"
opts.parse!(ARGV)

if (@directories.empty? || @command.empty?) then
	puts opts; exit
end

runner = Runner.new(@command, @success, @failure)
runner.latency = 0.2
runner.watch_directories @directories
runner.start
