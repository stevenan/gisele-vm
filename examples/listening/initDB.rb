require 'sequel'

class InitDB

	DB = Sequel.sqlite('myDB.db')

        ### Create patient table if it doesn't exist
	if not DB.table_exists?(:patient)
		DB.create_table :patient do
		  primary_key String :name
		  String :treatmentname
		  String :treatmentdate
		end
		#insert a patient example
		#patient_set = DB[:patient]
		#patient_set.insert(:name => 'Jean', :treatmentname => '', :treatmentdate => '15/07/2013')
	end

	### Create variable table if it doesn't exist
	if not DB.table_exists?(:fluent)
		DB.create_table :fluent do
		  String :fluentname
		  String :patientname
		  String :value
		end
	end

	### Create treatment table if it doesn't exist
	if not DB.table_exists?(:treatment)
		DB.create_table :treatment do
		  primary_key String :name
		  String :description
		  String :starttask
		end
		#insert a treatment example
		treatment_set = DB[:treatment]
		treatment_set.insert(:name => 'Treatment', :description => 'An example of treatment', :starttask => 'Consultation')
	end

        ### Create task info instance table if it doesn't exist
	if not DB.table_exists?(:taskinfo)
		DB.create_table :taskinfo do
		  String :taskname
		  String :treatmentname
		  String :precondition
		  Boolean :decision
		end
		#insert a task examples
		taskinfo_set = DB[:taskinfo]
		taskinfo_set.insert(:taskname => 'Consultation', :treatmentname => 'Treatment', :precondition => "", :decision => false)
		taskinfo_set.insert(:taskname => 'Endoscopy', :treatmentname => 'Treatment', :precondition => "", :decision => false)
		taskinfo_set.insert(:taskname => 'Chemotherapy', :treatmentname => 'Treatment', :precondition => "", :decision => false)
		taskinfo_set.insert(:taskname => 'Biopsy', :treatmentname => 'Treatment', :precondition => "", :decision => false)
		taskinfo_set.insert(:taskname => 'Surgery', :treatmentname => 'Treatment', :precondition => "", :decision => false)
	end

	### Create current task instance table if it doesn't exist
	if not DB.table_exists?(:taskinstance)
		DB.create_table :taskinstance do
		  primary_key Int :vmid
		  String :taskname
		  String :treatmentname
		  String :patientname
		  Time :starttime
		  Time :endtime
		end
		#insert a task info examples
		taskinstance_set = DB[:taskinstance]
		taskinstance_set.insert(:taskname => 'Consultation', :treatmentname => 'Treatment', :patientname => "steven")
		taskinstance_set.insert(:taskname => 'Endoscopy', :treatmentname => 'Treatment', :patientname => "steven")
	end


end
