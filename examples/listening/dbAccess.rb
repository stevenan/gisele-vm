require 'sequel'

class DBAccess

	def initialize
		@DB = Sequel.sqlite('myDB.db')
		@mean_time = Hash.new
		@taskinfo_set = @DB[:taskinfo]
		@currenttask_set = @DB[:currenttask]
		@patient_set = @DB[:patient]
		@treatment_set = @DB[:treatment]
		@variable_set = @DB[:variable]
	end


	def createCurrentTask(id, name, treatment, patient)
		Int time = @taskinfo_set.where(:taskname=>name).get(:meantime)
		@currenttask.insert(:vmid=>id, :taskname=>name, :treatmentname=>treatment, :patientname=>patient, :timeleft=>time)
		
	end

	def updateMean(taskname,value)
		@taskinfo_set.where(:taskname => taskname).update(:meantime => value)
	end

	def updateTimer
		array = @currenttask_set.select_map(:timeleft)
		array.take_while{|i| i>0}.each{|i| currenttask_set.where(:id=>i).update(:id=>i-1)}
	end

	def getPatientArray
		@patient_set.select_map(:name)
	end

	def getTreatmentArray
		@treatment_set.select_map(:name)
	end
	
	def addPatient(name)
		@patient_set.insert(:name => name)
	end

	def addVar(patient, var, value)
		@variable_set.insert(:varname => var, :patientname => patient, :value=>value)
	end
	
	def updateVar(patient, variable, value)
		@variable_set.where(:varname => variable, :patientname => patient).update(:value=>value)
	end
	
	def getPatientInfo(name)
		patient_info = @variable_set.where(:patientname => name).to_hash(:varname, :value)
	end

end
