require 'sequel'

class InitDB

	DB = Sequel.sqlite('myDB.db')

        ### Create patient table if it doesn't exist
	if not DB.table_exists?(:patient)
		DB.create_table :patient do
		  primary_key String :name
		  String :treatmentname
		  String :treatmentdate
		  Int :treatmentcounter
		end
	end
	#insert a patient example
	patient_set = DB[:patient]
	patient_set.delete
	patient_set.insert(:name => 'Jean', :treatmentname => '', :treatmentdate => '', :treatmentcounter=>0)
	patient_set.insert(:name => 'Pierre', :treatmentname => '', :treatmentdate => '', :treatmentcounter=>0)
	patient_set.insert(:name => 'Paul', :treatmentname => '', :treatmentdate => '', :treatmentcounter=>0)
	patient_set.insert(:name => 'John', :treatmentname => '', :treatmentdate => '', :treatmentcounter=>0)

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
	variable_set.insert(:variablename=>"Height", :patientname=>"Jean", :value=>"150")
	variable_set.insert(:variablename=>"Weight", :patientname=>"Paul", :value=>"50")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"Jean", :value=>"14")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"Pierre", :value=>"15")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"Paul", :value=>"11")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"John", :value=>"13")

	### Create treatment table if it doesn't exist
	if not DB.table_exists?(:treatment)
		DB.create_table :treatment do
		  primary_key String :name
		  String :description
		  String :starttask
		  Int :counter
		end
	end
	#insert a treatment example
	treatment_set = DB[:treatment]
	treatment_set.delete
	treatment_set.insert(:name => 'Treatment', :description => 'An example of treatment', :starttask => 'Consultation', :counter=>0)


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
	taskinfo_set.insert(:taskname => 'Consultation', :treatmentname => 'Treatment', :condition => "Blood pressure > 9", :place=>"", :decision => false)
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
		  String :conditionfailure
		end
	end
	#insert a task info examples
	taskinstance_set = DB[:taskinstance]
	taskinstance_set.delete
	#taskinstance_set.insert(:taskname => 'Surgery', :treatmentname => 'Treatment', :patientname => "Paul", :starttime => "", :endtime => "")
	#taskinstance_set.insert(:taskname => 'Surgery', :treatmentname => 'Treatment', :patientname => "Joe", :starttime => "", :endtime => "2")


end
