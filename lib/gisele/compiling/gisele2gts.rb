module Gisele
  module Compiling
    class Gisele2Gts < Sexpr::Rewriter
      grammar Language

      # if/elsif/else -> guarded commands
      use Language::IfToCase

      def gts
        options[:gts] ||= VM::Gts.new
      end

      def on_unit_def(sexpr)
        sexpr.
          sexpr_body.
          select{|n| n.first == :task_def}.
          map{|taskdef| apply(taskdef) }
      end

      def on_task_def(sexpr)
        entry_and_exit(:task) do |entry, exit|
          entry.initial!
          endevt = add_state(:event)
          apply(sexpr.last).tap do |c_entry, c_exit|
            connect(entry, c_entry, start_event(sexpr))
            connect(c_exit, endevt)
          end
          connect(endevt, exit, end_event(sexpr))
        end
      end

      def on_seq_st(sexpr)
        entry_and_exit do |entry, exit|
          current = entry
          sexpr.sexpr_body.each do |child|
            c_entry, c_exit = apply(child)
            connect(current, c_entry)
            current = c_exit
          end
          connect(current, exit)
        end
      end

      def on_par_st(sexpr)
        entry_and_exit(:forkjoin) do |entry, exit|
          sexpr.sexpr_body.each do |child|
            c_entry, c_exit = apply(child)
            c_end = add_state(:end)
            connect(entry,  c_entry)
            connect(c_exit, c_end)
            connect(c_end, exit)
          end
        end
      end

      def on_task_call_st(sexpr)
        entry_and_exit(:forkjoin) do |entry,exit|
          task_nodes(sexpr) do |c_entry,c_exit|
            connect(entry, c_entry, :symbol => :forked)
            connect(c_exit, exit,   :symbol => :notify)
          end
        end
      end

    private

      def task_nodes(sexpr)
        entry_and_exit(:task) do |entry,exit|
          listen = add_state(:listen, :accepting => true)
          endevt = add_state(:event)
          connect(entry, listen, start_event(sexpr))
          connect(listen, endevt, :symbol => :ended)
          connect(endevt, exit, end_event(sexpr))
          yield(entry, exit) if block_given?
        end
      end

      def start_event(sexpr)
        {:symbol => :start, :event_args => [ sexpr[1] ]}
      end

      def end_event(sexpr)
        {:symbol => :end, :event_args => [ sexpr[1] ]}
      end

      def add_state(kind = :nop, attrs = {})
        gts.add_state({:kind => kind}.merge(attrs))
      end

      def entry_and_exit(kind = :nop)
        gts.add_n_states(2).tap do |entry, exit|
          case kind
          when :nop
            entry[:kind] = :nop
            exit[:kind]  = :nop
          when :task
            entry[:kind] = :event
             exit[:kind] = :end
          when :event
            entry[:kind] = :event
            exit[:kind]  = :event
          when :startend
            entry[:kind] = :nop
             exit[:kind] = :end
          when :forkjoin
            entry[:kind] = :fork
             exit[:kind] = :join
             exit[:accepting] = true
            entry[:join] = exit.index
          else
            raise ArgumentError, "Unknown state kind: #{kind}"
          end
          yield(entry, exit) if block_given?
        end
      end

      def connect(source, target, attrs={})
        gts.connect(source, target, {:symbol => nil}.merge(attrs))
      end

    end # class Gisele2Gts
  end # module Compiling
end # module Gisele
