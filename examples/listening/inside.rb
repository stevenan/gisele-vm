$:.unshift File.expand_path('../../../lib', __FILE__)
require 'gisele-vm'
require_relative 'myGUI'

class Listener

  def initialize(gui)
    @start_array=[] #Array used to store id of started tasks
    @end_array=[] #Array used to store id of ended tasks
    @start_time=Hash.new #Hash used to store start time of tasks
    @task_end_time=Hash.new{|hash,key| hash[key]=[]} #hash used to store time needed for tasks
    @gui=gui
  end
  
  def call(event)
    prog      = event.prog
    type      = event.type
    task_name = event.args.first
    puts "SEEN: #{task_name}:#{type} (#{prog.puid} with parent #{prog.root})"
    
    if "#{type}"=="start" && prog.puid!=prog.root #new treatments are handled by the gui
	@gui.createTaskInstance(prog.puid, task_name)
    end
    
    #If a task is started
    if "#{type}"=="start" && !@start_array.include?("#{prog.puid}")
        @start_array.push("#{prog.puid}") #Add the id in the start array
        @start_time["#{prog.puid}"]=Time.now #Define the start time of the task and store it in the map
    
    #Else if a task is ended
    elsif "#{type}"=="end"
	if prog.puid==prog.root #end of treatment
		@gui.endTreatment
	end
	@gui.updateFrame
=begin
        @start_array.delete("#{prog.puid}") #Delete the id of the task in the started task array
        @end_array.push("#{prog.puid}") #Add it to the ended task array
        time_needed=Time.now-@start_time["#{prog.puid}"] #Compute the time needed to do the tasks
        puts "Task #{prog.puid} #{task_name} finished after #{time_needed.round.to_i} seconds"
        @task_end_time["#{task_name}"].push(time_needed) #Store the time needed
        sum_duration=0
        @task_end_time["#{task_name}"].each{|e| sum_duration+=e} #Sum all duration of all occurences of a task
        size=@task_end_time["#{task_name}"].length
        mean=sum_duration/size #Compute mean
        puts "Mean time of #{task_name} is #{mean}"
        sum_variance=0
        @task_end_time["#{task_name}"].each{|e| sum_variance+=(e-mean)**2}
        variance=sum_variance/size #Compute variance
        puts "Variance is equal to #{variance}"
=end
    end
=begin
    puts "Tasks started but not ended yet : #{@start_array.inspect}"
    puts "Tasks ended : #{@end_array.inspect}"
=end
  end
  
end

unless ARGV.size == 1
  puts "Usage: ruby vm_listen.rb GIS_FILE"
  exit
end

# Compile the .gis file as a bytecode
gis_file = Path(ARGV.first)
bytecode = Gisele::VM.compile(gis_file)

Gisele::VM.new(bytecode) do |vm|
  vm.logger = Logger.new(STDOUT)
  vm.logger.level = Logger::INFO

  # Register an enacter (force maximal progress by starting tasks)
  vm.register Gisele::VM::Enacter.new

  # Register the interactive console
  vm.register Gisele::VM::Console.new

  #GUI
  gui = MyGUI.new(vm)

  # Subscribe our listener to the VM events
  vm.subscribe Listener.new(gui)

  # trap CTRL-C and shut down the VM
  trap('INT'){
    vm.info "Interrupt on user request (graceful shutdown)."
    vm.stop
  }

end.run
