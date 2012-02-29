module Gisele
  class VM
    module Opcodes

    private

      ### CURRENT PROGRAM HANDLING #######################################################

      # Puts the puid of the executing Prog on the stack
      def op_puid
        push puid
      end

      ### GETTING PROGS ON STACK #########################################################

      # Pops an puid. Fetches and pushes the corresponding program.
      def op_fetch
        push fetch(pop)
      end

      # Pops an puid. Creates a child program of it. Registers that child and
      # pushes its puid back on the stack.
      def op_new
        push register(Prog.new(:parent => pop))
      end

       ### CODE STACK MANAGEMENT #########################################################

      # Pops a label. Pushes opcodes at that location on the code stack.
      def op_pushc
        enlist_bytecode_at(pop)
      end

      ### DATA STACK MANAGEMENT ##########################################################

      # Pushes `arg` on the data stack.
      def op_push(arg)
        push arg
      end

      # Pops the top element from the stack.
      def op_pop
        pop
      end

      # Pops `n` elements from the stack, keep them in a new array and push the later
      # back on the stack. If `n` is not provided, it is taken from the stack first.
      def op_group(nb = nil)
        n, arr = (nb || pop), []
        n.times{ arr << pop }
        push arr.reverse
      end

      # Pops an array of argument `args`. Pops a method name `m` (Symbol). Pops an object
      # `o`. Invoke `m` on `o`, passing arguments `args`. Push the result on the stack.
      def op_send
        args = pop
        m = pop
        o = pop
        push o.send(m, *args)
      end

      # Same as `op_send` but does not keep the result on the stack.
      def op_invoke
        op_send
        op_pop
      end

      ### TOP PROGRAM HANDLING ###########################################################

      # Pushes the parent puid of the top program.
      def op_parent
        push peek.parent
      end

      # Pushes the program counter of the top program.
      def op_pc
        push peek.pc
      end

      # Pops a label. Sets the program counter of the top program to it.
      def op_setpc
        label = pop
        peek.pc = label
      end

      # Set the `start` attribute to true on the top program
      def op_start
        peek.start = true
      end

      # Set the `start` attribute to false on the top program
      def op_stop
        peek.start = false
      end

      # Pops the top program from the stack. Saves it. Pushes its puid back on
      # the stack.
      def op_save
        push save(pop)
      end

      # Pops an puid. Adds it to the notifying list of the peek program.
      def op_wait
        puid = pop
        peek.wait << puid
      end

      # Pops a puid. Removes it from the wait list of the peek program.
      def op_notify
        puid = pop
        peek.wait.delete puid
      end

      # Pops a label. If the wait list of the peek program is empty then pushes
      # the opcodes at that location on the code stack. Otherwise do nothing.
      def op_resume
        label = pop
        enlist_bytecode_at(label) if peek.wait.empty?
      end

      ### EVENT HANDLING #################################################################

      # Pops event arguments from the stack (an array). Send an event of the specified
      # kind on the event interface. If `kind` is not provided, it is first poped from
      # the stack
      def op_event(kind = nil)
        kind ||= pop
        args = pop
        event(kind, args)
      end

    end # module Opcodes
  end # class VM
end # module Gisele
