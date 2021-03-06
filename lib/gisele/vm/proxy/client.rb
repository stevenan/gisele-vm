require 'drb'
module Gisele
  class VM
    module Proxy
      class Client
        extend  Forwardable

        attr_reader   :options
        attr_accessor :logger
        attr_reader   :registry

        def initialize(options = {})
          init_lifecycle
          @options  = Proxy.default_options.merge(options)
          @registry = Registry.new(self)
          yield(self) if block_given?
          @logger ||= Logger.new($stdout, Logger::DEBUG)
        end

        include Robustness
        include Logging
        include Lifecycle

        def run
          DRb.start_service
          @vm = DRbObject.new nil, options[:uri]
          @vm.to_s
          yield(@vm) if block_given?
          super
        end

        def stop
          DRb.stop_service
          super
        end

        def_delegators :registry,      :components,
                                       :register,
                                       :unregister,
                                       :connect,
                                       :disconnect,
                                       :connected?
        def_delegators :"@vm",         :proglist,
                                       :event_manager
        def_delegators :"@vm",         :start,
                                       :resume,
                                       :progress
        def_delegators :"@vm",         :pick,
                                       :fetch,
                                       :save,
                                       :progs
        def_delegators :"@vm",         :event,
                                       :subscribe,
                                       :unsubscribe

      end # Client
    end # module Proxy

    def self.drb_client(&bl)
      Proxy::Client.new.run(&bl)
    end

  end # class VM
end # module Gisele
