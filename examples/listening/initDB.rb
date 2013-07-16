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
		#insert a treatment example
		treatment_set = DB[:patient]
		treatment_set.insert(:name => 'Jean', :treatmentname => 'Treatment 1', :treatmentdate => '15/07/2013')
	end

	### Create variable table if it doesn't exist
	if not DB.table_exists?(:variable)
		DB.create_table :variable do
		  String :varname
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
		treatment_set.insert(:name => 'Treatment 1', :description => 'an example of treatment', :starttask => 'Consultation')
	end

        ### Create task info instance table if it doesn't exist
	if not DB.table_exists?(:taskinfo)
		DB.create_table :taskinfo do
		  String :taskname
		  String :treatmentname
		  Int :meantime
		  Float :variance
		  String :precondition
		  Boolean :decision
		  String :nexttask
		end
	end

	### Create current task instance table if it doesn't exist
	if not DB.table_exists?(:currenttask)
		DB.create_table :currenttask do
		  primary_key Int :vmid
		  String :taskname
		  String :treatmentname
		  String :patientname
		  Int :timeleft
		end
	end


end
