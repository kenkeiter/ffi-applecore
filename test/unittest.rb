require 'test/unit'
require 'rubygems'
require 'applecore'

class SystemLoggerTest < Test::Unit::TestCase
  
  def setup
    @asl = Apple::SystemLogger.new('TestApp', 'user', STDERR)
  end

  def teardown
    @asl.close
  end
  
  def test_severities
        
    @asl.emergency "Oh god I bet that burns!"
    @asl.alert "What happened to all the oxygen?!"
    @asl.critical "At this point all you can hope for is a quick death."
    @asl.error "Your heart appears to be stopping..."
    @asl.warning "You may die... Just a thought."
    @asl.info "You're dead."
    @asl.debug "Can't debug. You're dead."
    
    @asl << "Debug message-tastic."
    
  end
  
end