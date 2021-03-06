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
	patient_set.insert(:name => 'Paul', :treatmentname => '', :treatmentdate => '')
	patient_set.insert(:name => 'John', :treatmentname => '', :treatmentdate => '')

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
	variable_set.insert(:variablename=>"Height", :patientname=>"Jean", :value=>"152")
	variable_set.insert(:variablename=>"Height", :patientname=>"Pierre", :value=>"150")
	#variable_set.insert(:variablename=>"Height", :patientname=>"Paul", :value=>"150")
	variable_set.insert(:variablename=>"Weight", :patientname=>"Jean", :value=>"50")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"Jean", :value=>"14")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"Pierre", :value=>"15")
	variable_set.insert(:variablename=>"Blood pressure", :patientname=>"Paul", :value=>"11")
	#variable_set.insert(:variablename=>"Blood pressure", :patientname=>"John", :value=>"13")

	### Create treatment table if it doesn't exist
	if not DB.table_exists?(:treatment)
		DB.create_table :treatment do
		  primary_key String :name
		  String :description
		  String :starttask
		  String :fluents
		  Int :counter
		end
	end
	#insert a treatment example
	treatment_set = DB[:treatment]
	treatment_set.delete
	treatment_set.insert(:name => 'Treatment', :description => 'An example of treatment', :starttask => 'Consultation', :fluents=>'consultation_f, endoscopy_f, biopsy_f, chemotherapy_f, surgery_f', :counter=>0)


        ### Create task info table if it doesn't exist
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
	taskinfo_set.insert(:taskname => 'Consultation', :treatmentname => 'Treatment', :condition => "Blood pressure >= 14, Height = 150", :place=>"", :decision => false)
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


	### Create fluent info table if it doesn't exist
	if not DB.table_exists?(:fluentinfo)
		DB.create_table :fluentinfo do
		  String :fluentname
		  Boolean :initialvalue
		  String :initiatingevent
		  String :endingevent
		end
	end
	#insert a fluent info examples
	fluentinfo_set = DB[:fluentinfo]
	fluentinfo_set.delete
	fluentinfo_set.insert(:fluentname=>'consultation_f', :initialvalue=>false, :initiatingevent=>'Consultation', :endingevent=>'Surgery')
	fluentinfo_set.insert(:fluentname=>'endoscopy_f', :initialvalue=>false, :initiatingevent=>'Endoscopy', :endingevent=>'Surgery')
	fluentinfo_set.insert(:fluentname=>'biopsy_f', :initialvalue=>false, :initiatingevent=>'Biopsy', :endingevent=>'Surgery')
	fluentinfo_set.insert(:fluentname=>'chemotherapy_f', :initialvalue=>false, :initiatingevent=>'Chemotherapy', :endingevent=>'Surgery')
	fluentinfo_set.insert(:fluentname=>'surgery_f', :initialvalue=>false, :initiatingevent=>'Surgery', :endingevent=>'')

	### Create fluent instance table if it doesn't exist
	if not DB.table_exists?(:fluentinstance)
		DB.create_table :fluentinstance do
		  String :fluentname
		  Boolean :value
		  String :patientname
		end
	end
	#insert a fluent info examples
	fluentinstance_set = DB[:fluentinstance]
	fluentinstance_set.delete

end
