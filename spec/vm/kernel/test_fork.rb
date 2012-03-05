require 'spec_helper'
module Gisele
  class VM
    describe "kernel::fork" do

      let(:list)  { ProgList.memory                       }
      let(:vm)    { VM.new @parent, Bytecode.kernel, list }
      let(:parent){ list.fetch(@parent)                   }

      before do
        @parent = list.save Prog.new(:pc => :fork)
        subject
      end

      subject do
        vm.run(:fork, [ :joinat, [ :fat1, :fat2 ] ])
      end

      after do
        vm.stack.should be_empty
      end

      it 'sets the events as waitlist' do
        parent.waitlist.should eq({1 => true, 2 => true})
      end

      it 'fork and schedules self and children correctly' do
        expected = Relation([
          {:puid => 0, :pc => :joinat, :parent => 0, :progress => false},
          {:puid => 1, :pc => :fat1,   :parent => 0, :progress => true},
          {:puid => 2, :pc => :fat2,   :parent => 0, :progress => true}
        ])
        list.to_relation.project([:puid, :pc, :parent, :progress]).should eq(expected)
      end

    end
  end
end
