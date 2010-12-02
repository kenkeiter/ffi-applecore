require 'test/unit'
require 'rubygems'
require 'applecore'

class SystemLogTest < Test::Unit::TestCase

  def setup
    @log = Apple::SystemLogger.new('TestApp', 'user')
  end
  
  def teardown
    @log.close
  end

  def test_severities
    message = 'Test'
    assert_equal(0, @log.emergency(message), 'Log emergency message failed.')
    assert_equal(0, @log.alert(message), 'Log alert message failed.')
    assert_equal(0, @log.critical(message), 'Log critical message failed.')
    assert_equal(0, @log.error(message), 'Log error message failed.')
    assert_equal(0, @log.warning(message), 'Log warning message failed.')
    assert_equal(0, @log.info(message), 'Log info message failed.')
    assert_equal(0, @log.debug(message), 'Log debug message failed.')
    assert_equal(0, @log << message, 'Log debug shorthand failed.')
  end
  
end

class SystemLogFileTest < Test::Unit::TestCase

  def setup
    @filename = 'unittest.log'
    @log = Apple::SystemLogger.new('TestApp', 'user', @filename)
  end

  def teardown
    @log.close
    File.delete(@filename)
  end
  
  def test_severities
    # write message
    assert_equal(0, @log.info('Test info'), 'Log info message failed.')
    assert_equal(0, @log.debug('Test debug'), 'Log debug message failed.')
    assert_equal(0, @log << 'Test debug', 'Log debug shorthand failed.')
    # ensure messages were written.
    fp = File.new(@filename, 'r')
    content = fp.read()
    fp.close
    # verify tests written
    assert_equal(1, content.scan(/Test info/).length, 'Logging of info message failed.')
    assert_equal(2, content.scan(/Test debug/).length, 'Logging of debug message failed.')
  end
  
end