require 'singleton'
require 'ffi'

module Apple
  
  module CoreServices
    extend FFI::Library
    ffi_lib File.join(File.expand_path(File.dirname(__FILE__)), 'libapplecore.dylib')

    attach_function :asl_create_context, [:string, :string, :uint], :pointer
    attach_function :asl_finalize_context, [:pointer], :int
    attach_function :asl_log_event, [:pointer, :uchar, :string], :int
    attach_function :asl_add_output_file, [:pointer, :int], :int
    attach_function :asl_remove_output_file, [:pointer, :int], :int

    attach_function :launchd_register, [], :int # careful.. segfaults if not part of ld.
  end
  
  class Launchd
    
    include Singleton
    attr_reader :registered
    
    def initialize
      @registered = false
    end
    
    def register
      unless @registered
        if CoreServices::launchd_register() == 0
          @registered = true
        end
      end
    end
    
  end
  
  class SystemLogger
    
    def initialize(app_name, facility='user', dest=nil)
      @context = CoreServices::asl_create_context(app_name, facility)
      @log_fp = nil
      
      unless dest.nil?
        if dest.is_a? String
          @log_fp = File.new(dest,  "w+")
          dest = @log_fp.to_i
          at_exit{ @log_fp.close } # attach close handler
        end
        CoreServices::asl_add_output_file(@context, dest.to_i)
      end
      
    end
    
    def log(sev, msg)
      CoreServices::asl_log_event(@context, sev, msg)
    end
    
    def close
      @log_fp.close if @log_fp
      CoreServices::asl_finalize_context(@asl)
    end
    
    def emergency(msg) log(0, msg); end
    def alert(msg) log(1, msg); end
    def critical(msg) log(2, msg); end
    def error(msg) log(3, msg); end
    def warning(msg) log(4, msg); end
    def notice(msg) log(5, msg); end
    def info(msg) log(6, msg); end
    def debug(msg) log(7, msg); end
    def <<(msg) debug(msg); end
    
  end
  
end