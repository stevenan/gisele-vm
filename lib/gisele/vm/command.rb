module Gisele
  class VM
    #
    # The Gisele Virtual Machine
    #
    # SYNOPSIS
    #   gvm [--version] [--help]
    #   gvm [--drb-server] [options] GIS_FILE
    #   gvm --drb-client [options]
    #
    # OPTIONS
    # #{summarized_options}
    #
    class Command <  Quickl::Command(__FILE__, __LINE__)

      # Install options
      options do |opt|
        opt.on('--help', "Show this help message") do
          raise Quickl::Help
        end
        opt.on('--version', 'Show version and exit') do
          raise Quickl::Exit, "gvm #{Gisele::VM::VERSION} (c) The University of Louvain"
        end

        @mode = :run
        opt.on('-c', '--compile', 'Compile the input file and output the VM bytecode') do
          @mode = :compile
        end
        opt.on('-g', '--gts', 'Outputs a gisele transition system') do
          @mode = :gts
        end

        opt.separator("\nStorage")
        @storage = "memory"
        opt.on('--storage=URI',
               "Use the specified storage (defaults to 'memory')") do |uri|
          @storage = uri
        end
        @truncate = false
        opt.on('-t', '--truncate', 'Truncate process instances first') do
          @truncate = true
        end

        opt.separator("\nVM & Agents")
        @interactive = false
        opt.on('-i', '--interactive', 'Start a console in interactive VM mode') do
          @interactive = true
        end
        @simulation = false
        opt.on('-s', '--simulate', 'Use an agent simulating the environment') do
          @simulation = true
        end
        @drb_server = false
        opt.on('--drb-server', 'Register the VM as a DRb server') do
          @drb_server = true
        end
        @drb_client = false
        opt.on('--drb-client', 'Look for the virtual machine on DRb') do
          @drb_client = true
        end

        opt.separator("\nLogging")
        @verbose = Logger::INFO
        opt.on('-v', '--verbose', 'Log in verbose mode') do
          @verbose = Logger::DEBUG
        end
        opt.on('--silent', 'Only show warnings and errors') do
          @verbose = Logger::WARN
        end
        @log_file = $stdout
        opt.on('--log=FILE', 'Use a specific log file') do |file|
          @log_file = file
        end
      end

      def execute(args)
        raise Quickl::Help if args.size > 1
        @gis_file = Path(args.shift)
        case @mode
        when :run        then start_vm
        when :compile    then puts VM.compile(@gis_file)
        when :gts        then puts VM.gts(@gis_file).to_dot
        end
      end

      def vm(gis_file = @gis_file)
        @vm ||= @drb_client ? drb_vm : real_vm(gis_file)
      end

    private

      def real_vm(gis_file = @gis_file)
        bc = VM.compile(gis_file)
        VM.new(bc) do |vm|
          vm.proglist = VM::ProgList.new VM::ProgList.storage(@storage)
          vm.register VM::Enacter.new
          populate(vm)
        end
      end

      def drb_vm
        require_relative 'proxy'
        Proxy::Client.new{|vm| populate(vm) }
      end

      def populate(vm)
        # Install the logger
        vm.logger       = Logger.new(@log_file)
        vm.logger.level = @verbose

        # Add the simulation if required
        if @simulation
          require_relative 'simulator/resumer'
          vm.register Simulator::Resumer.new
        end

        # Add the DRb server if required
        if @drb_server
          require_relative 'proxy'
          vm.register Proxy::Server.new
        end

        if @interactive
          vm.register Console.new
        end
        vm
      end

      def start_vm
        the_vm = vm
        trap('INT'){
          the_vm.info "Interrupt on user request (graceful shutdown)."
          the_vm.stop
        }
        the_vm.run
      end

    end # class Command
  end # class VM
end # module Gisele
