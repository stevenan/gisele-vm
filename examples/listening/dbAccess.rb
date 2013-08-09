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
		@variable_set = @DB[:variable]
	end

	def updatetasktime(id, column)
		@taskinstance_set.where(:vmid=>id).update(column => Time.now)
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

	def updatePatient(name, treatment, date, increment)
		c=getPatientTreatmentCounter(name)
		@patient_set.where(:name => name).update(:treatmentname => treatment, :treatmentdate => date, :treatmentcounter=> c+increment)
	end

	def addVariable(patient, variable, value)
		@variable_set.insert(:variablename => variable, :patientname => patient, :value=>value)
	end
	
	def updateVariable(patient, variable, value)
		@variable_set.where(:variablename => variable, :patientname => patient).update(:value=>value)
	end
	
	def getPatientVariables(name)
		patient_info = @variable_set.where(:patientname => name).to_hash(:variablename, :value)
	end

	def getPatientTreatment(name)
		@patient_set.where(:name=>name).get(:treatmentname)
	end

	def getPatientTreatmentCounter(name)
		@patient_set.where(:name=>name).get(:treatmentcounter)
	end

	def getTreatmentCounter(treatment)
		@treatment_set.where(:name=>treatment).get(:counter)
	end

	def getTreatmentInProgress(treatment)
		@patient_set.where(:treatmentname).count
	end

	def getTreatmentDuration(treatment)
		total=0
		map=@taskinstance_set.exclude(:endtime=>"").where(:treatmentname=>treatment).select_map([:starttime, :endtime])
		map.each{ |s,e|
			total+=(e-s)
		}
		total.round(2)
	end

	def getTasksFromTreatment(treatment)
		@taskinfo_set.where(:treatmentname => treatment).select_map(:taskname)
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

	def getCondition(task, treatment)
		p=@taskinfo_set.where(:taskname => task, :treatmentname => treatment).select_map(:condition)
		p[0]
	end
	
	def getPatientDuration(patient)
		map=@taskinstance_set.exclude(:endtime=>"", :starttime=>"").where(:patientname=>patient).select_map([:starttime, :endtime])
		total=0
		map.each{ |s,e|
			total+=(e-s)
		}
		total.round(2)
	end

	def getTaskStats(task, treatment)
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
		[mean.round(2), variance.round(2)]
	end

	def getTaskFinishedNumber(task, treatment)
		@taskinstance_set.exclude(:endtime=>"").where(:taskname=>task, :treatmentname=>treatment).count
	end

	def getSuccessPercentage(task, treatment)
		total=@taskinstance_set.exclude(:endtime=>"").where(:taskname=>task, :treatmentname=>treatment).count
		failure=@taskinstance_set.exclude(:endtime=>"", :conditionfailure=>"").where(:taskname=>task, :treatmentname=>treatment).count
		percentage=0
		if total>0
			percentage=failure*100/total
		end
		percentage.round(2)
	end

	def getMostConditionFailure(task, treatment)
		counter_array=Hash.new
		c=@taskinstance_set.exclude(:endtime=>"").or(:conditionfailure=>"")
		c1=c.where(:taskname=>task, :treatmentname=>treatment).select_map(:conditionfailure)
		result=""

		if c1.length!=0
			c1.each{ |e| 

				if counter_array.include?(e)
					counter_array[e]+=1
				else
					counter_array[e]=1
				end
			}
			most=counter_array.max_by{|k,v| v}
			result=most[1]

		end

		result
	end

	def incrementTreatmentCounter(treatment)
		c=@treatment_set.where(:name=>treatment).get(:counter)
		@treatment_set.where(:name=>treatment).update(:counter=>c+1)
	end

end
