require 'sequel'
require 'date'
require 'time'

class DBAccess

	def initialize
		@DB = Sequel.sqlite('myDB.db')
		@mean_time = Hash.new
		@taskinfo_set = @DB[:taskinfo]
		@taskinstance_set = @DB[:taskinstance]
		@patient_set = @DB[:patient]
		@treatment_set = @DB[:treatment]
		@fluent_set = @DB[:fluent]
	end


	def createtaskinstance(id, name, treatment, patient)
		Int time = @taskinfo_set.where(:taskname=>name).get(:meantime)
		@taskinstance.insert(:vmid=>id, :taskname=>name, :treatmentname=>treatment, :patientname=>patient, :starttime=>Time.new, :endtime=>'')
		
	end

	def updateMean(taskname,value)
		@taskinfo_set.where(:taskname => taskname).update(:meantime => value)
	end

	def updateTimer
		array = @taskinstance_set.select_map(:timeleft)
		array.take_while{|i| i>0}.each{|i| taskinstance_set.where(:id=>i).update(:id=>i-1)}
	end

	def getPatientArray
		@patient_set.select_map(:name)
	end

	def getAvailablePatientArray
		@patient_set.where(:treatmentname => '').select_map(:name)
	end

	def getTreatmentArray
		@treatment_set.select_map(:name)
	end
	
	def addPatient(name)
		@patient_set.insert(:name => name, :treatmentname => '', :treatmentdate => '')
	end

	def updatePatient(name, treatment)
		@patient_set.where(:name => name).update(:treatmentname => treatment, :treatmentdate => Date.today.to_s)
	end

	def addFluent(patient, fluent, value)
		@fluent_set.insert(:fluentname => fluent, :patientname => patient, :value=>value)
	end
	
	def updateFluent(patient, fluent, value)
		@fluent_set.where(:fluentname => fluent, :patientname => patient).update(:value=>value)
	end
	
	def getPatientInfo(name)
		patient_info = @fluent_set.where(:patientname => name).to_hash(:fluentname, :value)
	end

end
