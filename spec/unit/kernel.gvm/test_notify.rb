require 'spec_helper'
module Gisele
  class VM
    describe Kernel, "notify macro" do

      let(:list)  { ProgList.memory                           }
      let(:vm)    { Kernel.new @child, Bytecode.kernel, list  }
      let(:parent){ list.fetch(@parent)                       }
      let(:child) { list.fetch(@child)                        }

      subject do
        vm.run(:notify, [ ])
      end

      after do
        vm.stack.should be_empty
      end

      context 'when the child has a parent' do

        before do
          @parent = list.save Prog.new(:waitlist => {1 => true, 2 => true})
          @child  = list.save Prog.new(:parent => @parent)
          subject
        end

        it 'ends the child' do
          child.pc.should eq(-1)
          child.progress.should be_false
        end

        it 'resumes the parent on a reduced waitlist' do
          parent.waitlist.should eq(2 => true)
          parent.progress.should be_true
        end

      end # with a parent

      context 'when the child has no parent' do

        before do
          @child = list.save Prog.new
          subject
        end

        it 'ends the child' do
          child.pc.should eq(-1)
          child.waitlist.should eq({})
          child.progress.should be_false
        end

      end # withoutb a parent

    end
  end
end