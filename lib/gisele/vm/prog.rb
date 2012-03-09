module Gisele
  class VM
    class Prog
      attr_accessor :puid
      attr_accessor :parent
      attr_accessor :root
      attr_accessor :pc
      attr_accessor :waitfor
      attr_reader   :waitlist
      attr_accessor :input

      def initialize(attrs = {})
        @puid     = attrs[:puid]     || nil
        @parent   = attrs[:parent]   || @puid
        @root     = attrs[:root]     || @puid
        @pc       = attrs[:pc]       || 0
        @waitfor  = attrs[:waitfor]  || :none
        @waitlist = attrs[:waitlist] || {}
        @input    = attrs[:input]    || []
      end

      def waitlist=(wlist)
        wlist = Hash[wlist.map{|x| [x,true]}] unless Hash===wlist
        @waitlist = wlist
      end

      def to_hash
        { :puid     => puid,
          :parent   => parent,
          :root     => root,
          :pc       => pc,
          :waitfor  => waitfor,
          :waitlist => waitlist,
          :input    => input }
      end

      def dup
        super.tap do |c|
          c.waitlist = waitlist.dup
          c.input    = input.dup
        end
      end

      def ==(other)
        other.is_a?(Prog) and (other.to_hash == to_hash)
      end
      alias :eql? :==

    end # class Prog
  end # class VM
end # module Gisele
