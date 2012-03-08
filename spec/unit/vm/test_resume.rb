require 'spec_helper'
module Gisele
  describe VM, "resume" do

    subject do
      vm.resume(@puid, [ :an_event ])
    end

    before do
      @puid = list.save VM::Prog.new(:pc => :hello, :waitfor => :world)
      subject
    end

    it 'creates a fresh new Prog instance and schedules it' do
      expected = Relation(:puid => @puid, :waitfor => :enacter, :input => [ :an_event ])
      list.to_relation.project([:puid, :waitfor, :input]).should eq(expected)
    end

    it 'detects invalid puids' do
      lambda{
        vm.resume(17, [])
      }.should raise_error(VM::InvalidPUIDError, "Invalid puid: `17`")
    end

    it 'detects invalid inputs' do
      lambda{
        vm.resume(@puid, 12)
      }.should raise_error(VM::InvalidInputError, "Invalid VM input: `12`")
    end

    it 'detects progs that do not wait for the world' do
      list.save(VM::Prog.new :puid => @puid, :waitfor => :enacter)
      lambda{
        vm.resume(@puid, [])
      }.should raise_error(VM::InvalidStateError, "Prog `#{@puid}` does not wait for world stimuli")
    end

  end
end
