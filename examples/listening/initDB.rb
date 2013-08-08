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
	end
	#insert a patient example
	patient_set = DB[:patient]
	patient_set.delete
	patient_set.insert(:name => 'Jean', :treatmentname => '', :treatmentdate => '')
	patient_set.insert(:name => 'Pierre', :treatmentname => '', :treatmentdate => '')

	### Create variable table if it doesn't exist
	if not DB.table_exists?(:variable)
		DB.create_table :variable do
		  String :variablename
		  String :patientname
		  String :value
		end
	end
	variable_set = DB[:variable]
	variable_set.delete
	variable_set.insert(:variablename=>"taille", :patientname=>"Jean", :value=>"150")
	variable_set.insert(:variablename=>"poids", :patientname=>"Jean", :value=>"50")

	### Create treatment table if it doesn't exist
	if not DB.table_exists?(:treatment)
		DB.create_table :treatment do
		  primary_key String :name
		  String :description
		  String :starttask
		end
	end
	#insert a treatment example
	treatment_set = DB[:treatment]
	treatment_set.delete
	treatment_set.insert(:name => 'Treatment', :description => 'An example of treatment', :starttask => 'Consultation')


        ### Create task info instance table if it doesn't exist
	if not DB.table_exists?(:taskinfo)
		DB.create_table :taskinfo do
		  String :taskname
		  String :treatmentname
		  String :condition
		  String :place
		  Boolean :decision
		end
	end
	#insert a task examples
	taskinfo_set = DB[:taskinfo]
	taskinfo_set.delete
	taskinfo_set.insert(:taskname => 'Consultation', :treatmentname => 'Treatment', :condition => "age > 5, taille > 50", :place=>"", :decision => false)
	taskinfo_set.insert(:taskname => 'Endoscopy', :treatmentname => 'Treatment', :condition => "", :place=>"", :decision => false)
	taskinfo_set.insert(:taskname => 'Chemotherapy', :treatmentname => 'Treatment', :condition => "", :place=>"", :decision => false)
	taskinfo_set.insert(:taskname => 'Biopsy', :treatmentname => 'Treatment', :condition => "", :place=>"", :decision => false)
	taskinfo_set.insert(:taskname => 'Surgery', :treatmentname => 'Treatment', :condition => "", :place=>"", :decision => false)


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
	end
	#insert a task info examples
	taskinstance_set = DB[:taskinstance]
	taskinstance_set.delete
	#taskinstance_set.insert(:taskname => 'Surgery', :treatmentname => 'Treatment', :patientname => "Paul", :starttime => "", :endtime => "")
	#taskinstance_set.insert(:taskname => 'Surgery', :treatmentname => 'Treatment', :patientname => "Joe", :starttime => "", :endtime => "2")


end
