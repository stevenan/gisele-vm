require 'spec_helper'
module Gisele
  class VM
    public :pop
    describe 'pop' do

      let(:vm){ VM.new 5, [] }

      before do
        vm.stack = [:a, :b, :c, :d]
      end

      it 'returns the poped object when n is not specified' do
        vm.pop.should eq(:d)
        vm.pop.should eq(:c)
        vm.stack.should eq([:a, :b])
      end

      it 'returns the poped objects when n is specified' do
        vm.pop(0).should eq([])
        vm.pop(2).should eq([:d, :c])
        vm.pop(1).should eq([:b])
      end

    end
  end
end
