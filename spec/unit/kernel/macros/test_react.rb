require 'spec_helper'
module Gisele
  class VM
    describe Kernel, "react macro" do

      let(:runn)  { runner(@parent)     }
      let(:parent){ list.fetch(@parent) }
      let(:wlist) { {:ping => :sPing, :pong => :sPong} }

      before do
        @parent = list.save Prog.new(:pc => :react, :waitlist => wlist, :waitfor => waitfor)
        subject
      end

      subject do
        runn.run(:react, [ event ])
      end

      after do
        runn.stack.should be_empty
      end

      context 'when a recognized event' do
        let(:event)  { :ping  }
        let(:waitfor){ :world }

        it 'schedules the current Prog correctly' do
          parent.pc.should eq(:sPing)
          parent.waitfor.should eq(:enacter)
          parent.waitlist.should eq({})
        end
      end

      context 'when an unrecognized event' do
        let(:event)  { :pang    }
        let(:waitfor){ :enacter }

        it 'sleeps the current Prog' do
          parent.pc.should eq(:react)
          parent.waitfor.should eq(:world)
          parent.waitlist.should eq(wlist)
        end
      end

    end
  end
end
