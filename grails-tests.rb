#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'rdoc/usage'
require 'pp'
require 'date'

require 'runner.rb'

@directory = ""
@directories = []

opts = OptionParser.new
opts.on('-d', '--directory DIR', 'Grails App Directory') do |opt|
	@directory = opt
	@directories << opt + "/grails-app"
	@directories << opt + "/src"
	@directories << opt + "/test"
end

opts.on('-s', '--selector SELECTOR', 'The Grails test selector [unit, integration, unit:spock SomeService, etc.]') do |opt|
	  @selector = opt
end

opts.on_tail('-h', '--help', 'Display this message') do
	puts opts
	exit
end

opts.banner = "Usage: ci-tool.rb [options]"
opts.parse!(ARGV)

if (@directories.empty?) then
	puts opts; exit
end

env = "-d32 -client -XstartOnFirstThread -Xverify:none -XX:-UseParallelOldGC -XX:+AggressiveOpts -XX:+UseConcMarkSweepGC -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled"
basename = `basename #{@directory}`

runner = Runner.new("#{env} cd #{@directory} && grails test-app #{@selector}", "Tests for #{basename} pass", "Tests for #{basename} failed")
runner.latency = 0.2
runner.watch_directories @directories
runner.start
