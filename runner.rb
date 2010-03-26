require 'rubygems'
require 'fsevent'
require 'ruby-growl'

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
