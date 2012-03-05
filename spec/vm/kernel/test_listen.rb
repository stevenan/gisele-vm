require 'spec_helper'
module Gisele
  class VM
    describe "kernel::listen" do

      let(:list)  { ProgList.memory                       }
      let(:vm)    { VM.new @parent, Bytecode.kernel, list }
      let(:parent){ list.fetch(@parent)                   }
      let(:wlist) { {:ping => :sPing, :pong => :sPong}    }

      before do
        @parent = list.save Prog.new(:pc => :listen)
        subject
      end

      subject do
        vm.run(:listen, [ wlist ])
      end

      after do
        vm.stack.should be_empty
      end

      it 'sets the events as waitlist' do
        parent.waitlist.should eq(wlist)
      end

      it 'sets the program counter to :react' do
        parent.pc.should eq(:react)
      end

      it 'unschedules the current Prog' do
        parent.progress.should be_false
      end

    end
  end
end
