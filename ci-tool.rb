require 'rubygems'
require 'fsevent'
require 'ruby-growl'


class RunTests < FSEvent
	def initialize
		@@growler = Growl.new "localhost", "ci-tool", ["Test Failed", "Test Success"], nil, "growler"
	end
	
	def growler
		@@growler
	end

	def on_change(directories)
		puts "Detected change in: #{directories.inspect}"
		system "cd /Users/jboyens/Workspace/commerce.git/LocalDirectory && " +
		       "JAVA_OPTS='-d32 -client -XstartOnFirstThread -Xverify:none " +
			   "-XX:-UseParallelOldGC -XX:+AggressiveOpts -XX:+UseConcMarkSweepGC " +
			   "-XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled' " +
			   "grails test-app unit:spock CouponService"
		if $?.exitstatus != 0
			growler.notify "Test Failed", "Test Failed", "Some or all of your shit is broke", 0, true
		else
			growler.notify "Test Success", "Test Success", "Congratulations, your shit ain't broke", 0, false
		end
	end

	def start
		puts "watching #{registered_directories.join(", ")} for changes"
		super
	end
end

basedir = "/Users/jboyens/Workspace/commerce.git/LocalDirectory"

runner = RunTests.new
runner.latency = 0.2
runner.watch_directories %W(#{basedir}/grails-app #{basedir}/src #{basedir}/test)
runner.start
