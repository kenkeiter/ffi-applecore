# ffi-applecore provides programatic access to the Apple System Logger 
# facilities, as well as support for proper launchd registration. Supports 
# Apple OS X only, versions
#
# Author:: Ken Keiter (mailto:noise@kenkeiter.com)
# License:: MIT License (see related LICENSE file)

require 'singleton'
require 'ffi'

module Apple
  
  LOG_LEVEL_EMERGENCY = 0
  LOG_LEVEL_ALERT = 1
  LOG_LEVEL_CRITICAL = 2
  LOG_LEVEL_ERROR = 3
  LOG_LEVEL_WARNING = 4
  LOG_LEVEL_NOTICE = 5
  LOG_LEVEL_INFO = 6
  LOG_LEVEL_DEBUG = 7
  
  # The CoreServices module provides the FFI abstraction of the libapplecore 
  # library, which encapsulates most of our core functionality.
  
  module CoreServices
    extend FFI::Library
    ffi_lib File.join(File.expand_path(File.dirname(__FILE__)), 'libapplecore.dylib')

    attach_function :asl_create_context, [:string, :string], :pointer
    attach_function :asl_finalize_context, [:pointer], :int
    attach_function :asl_log_event, [:pointer, :uchar, :string], :int
    attach_function :asl_add_output_file, [:pointer, :string], :int
    attach_function :asl_close_output_file, [:pointer, :int], :int

    attach_function :launchd_register, [], :int # careful.. segfaults if not part of ld.
  end
  
  # The Launchd class is a singleton which permits registration with Launchd 
  # exactly once per session. The Launchd class should only be used when 
  # being run from Launchd, otherwise it may cause a segfault (trying to 
  # access non-shared memory).
  
  class Launchd
    
    include Singleton
    attr_reader :registered
    
    def initialize
      @registered = false
    end
    
    def register
      return false if @registered
      if CoreServices::launchd_register() == 0
        @registered = true
      end
    end
    
  end
  
  # The SystemLogger class acts as an abstraction of the CoreServices 
  # module's Apple System Logger functionality. It provides different log 
  # levels.
  
  class SystemLogger
    
    # Initialize new Apple System Logger client.
    def initialize(app_name, facility='user', dest=nil)
      @context = CoreServices::asl_create_context(app_name, facility)
      @dest = nil
      
      unless dest.nil? and dest.is_a? String
        puts 'Info'
        @dest = CoreServices::asl_add_output_file(@context, dest)
      end
      
    end
    
    # Write a message to the system log.
    def log(sev, msg)
      unless sev.to_i >= 0 && sev.to_i <= 7
        raise RangeError, 'Severity must be between 0..7 (inclusive).'
      end
      unless @context
        raise RuntimeError, 'System log client closed already.'
      end
      CoreServices::asl_log_event(@context, sev, msg)
    end
    
    # Close the connection to the Apple System Log service.
    def close
      CoreServices::asl_close_output_file(@context, @dest.to_i) if @dest
      CoreServices::asl_finalize_context(@context)
      @context = nil
    end
    
    # Log an emergency message. Emergency events are the highest priority, 
    # usually reserved for catastrophic failures and reboot notices. Note 
    # that emergency-level messages are typically broadcast to all open 
    # terminal sessions.
    def emergency(msg) log(0, msg); end
    
    # Log an alert message. Alert messages are typically indicative of a 
    # *serious* failure in a key system, and may be broadcast to all 
    # open terminals. 
    def alert(msg) log(1, msg); end
    
    # Log a critical message. Critical messages indicate a failure 
    # (non-serious) in a key system.
    def critical(msg) log(2, msg); end
    
    # Log an error message. Errors indicate a simple failure.
    def error(msg) log(3, msg); end
    
    # Log a warning message. Something is wrong, and may cause a more serious 
    # failure if not corrected.
    def warning(msg) log(4, msg); end
    
    # Log a notice -- something of moderate interest to the user or admin. 
    def notice(msg) log(5, msg); end
    
    # Log some info. Info is the lowest priority, and is purely informational. 
    def info(msg) log(6, msg); end
    
    # Log a debug message. The lowest priority, and normally not logged 
    # except for messages from the kernel.
    def debug(msg) log(7, msg); end
    
    # Log a debug message (shorthand).
    def <<(msg) debug(msg); end
    
  end
  
end