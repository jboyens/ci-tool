#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'rdoc/usage'
require 'pp'
require 'date'

require 'rubygems'
require 'fsevent'
require 'ruby-growl'

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

class Runner < FSEvent
	def initialize(command, success, failure)
		@@growler = Growl.new "localhost", "ci-tool", ["Command Failed", "Command Succeeded"]

		@command = command
		@success = success
		@failure = failure
	end
	
	def growler
		@@growler
	end

	def command
		@command
	end

	def success
		@success
	end

	def failure
		@failure
	end

	def on_change(directories)
		puts "Detected change in: #{directories.inspect}"
		system command
		if $?.exitstatus != 0
			# This is notify (type, header, body, priority, sticky)
			# sticky seems broken
			growler.notify "Command Failed", "Command Failed", failure, 0, true
		else
			growler.notify "Command Succeeded", "Command Succeeded", success, 0, false
		end
	end

	def start
		puts "watching #{registered_directories.join(", ")} for changes"
		super
	end
end

runner = Runner.new(@command, @success, @failure)
runner.latency = 0.2
runner.watch_directories @directories
runner.start
