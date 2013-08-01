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

	def updatetasktime(id, column)
		@taskinstance_set.where(:vmid=>id).update(column => Time.now)
	end

	def updateMean(taskname,value)
		@taskinfo_set.where(:taskname => taskname).update(:meantime => value)
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
	
	def getPatientFluents(name)
		patient_info = @fluent_set.where(:patientname => name).to_hash(:fluentname, :value)
	end

	def getPatientTreatment(name)
		@patient_set.where(:name=>name).get(:treatmentname)
	end

	def getTaskInstances
		task_instances = @taskinstance_set.where(:endtime=>"").select_map([:vmid, :patientname, :treatmentname , :taskname])
	end

	def addTaskInstance(id, patient, task, treatment)
		@taskinstance_set.insert(:vmid=>id, :taskname => task, :treatmentname => treatment, :patientname => patient, :starttime=>"", :endtime=>"")
	end

	def isStarted(id)		
		t = @taskinstance_set.where(:vmid=>id, :starttime=>"").select_map(:taskname)
		not t.length==0
	end

	def getTime(task, treatment)
		times=@taskinstance_set.exclude(:endtime=>"").where(:taskname=>task, :treatmentname=>treatment).select_map([:starttime, :endtime])
		duration=[]
		times.each{|s,e| duration.push(e-s)}
		total=0
		variance=0
		mean=0
		if (duration.length > 0)
			duration.each{|t| total+=t}
			mean=total/(duration.length)
			duration.each{|t| variance+=((t-mean)**2)}
		end
		[mean, variance]
	end

end
