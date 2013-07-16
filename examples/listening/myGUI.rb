require 'tk'
load 'dbAccess.rb'

class MyGUI
	
	root = TkRoot.new do
	  minsize(200,200)
	  title "Main"
	end
	
	$dbAccess = DBAccess.new	
	
	#Column of the main window
	br = ["Patient name", "Treatment", "Current task", "Warning", "Buttons"].collect {|c|
	  TkLabel.new(root, "text"=>c, "borderwidth"=>5, "relief"=>"ridge", "width"=>20)
	}
	TkGrid.grid(br[0], br[1], br[2], br[3], br[4])


	#Lines to separate data
	s0 = Tk::Tile::Separator.new(root) do
	   orient 'vertical'
	   place('height' => 180, 'x' => 172, 'y' => 30)
	end
	s1 = Tk::Tile::Separator.new(root) do
	   orient 'vertical'
	   place('height' => 180, 'x' => 344, 'y' => 30)
	end
	s2 = Tk::Tile::Separator.new(root) do
	   orient 'vertical'
	   place('height' => 180, 'x' => 516, 'y' => 30)
	end
	s3 = Tk::Tile::Separator.new(root) do
	   orient 'vertical'
	   place('height' => 180, 'x' => 688, 'y' => 30)
	end


	#window generated from menu
	newTreatment_proc = Proc.new {
	  TkToplevel.new(root){
	    title "New Treatment"
	  }
	}
	newPatient_proc = Proc.new {
	  TkToplevel.new(root){
	    title "New Treatment"
	  }
	}

	################# new Treatment window
	newt_win=Proc.new{
	  $win = TkToplevel.new{ title "New Treatment" }
		TkLabel.new($win) {
		  text "Treatment"
		  font TkFont.new('times 12 bold')
		  grid('row'=>0, 'column'=>0)
		}
		TkLabel.new($win) {
		  text "Patient"
		    font TkFont.new('times 12 bold')
		  grid('row'=>0, 'column'=>1)
		}

		f1 = TkFrame.new($win) {
		  padx 15
		  pady 20
		  grid('row'=>1, 'column'=>0)
		}
		bar = TkScrollbar.new(f1).pack('side'=>'right', 'fill'=>'y')
		list = TkListbox.new(f1).pack('side'=>'left', 'fill'=>'both', 'expand'=>true)
		treatment_array = $dbAccess.getTreatmentArray
                treatment_array.each{|i|
			list.insert('end', i)
		}
		list.yscrollbar(bar)
		f2 = TkFrame.new($win) {
		  padx 15
		  pady 20
		  grid('row'=>1, 'column'=>1)
		}
		bar = TkScrollbar.new(f2).pack('side'=>'right', 'fill'=>'y')
		list = TkListbox.new(f2).pack('side'=>'left', 'fill'=>'both', 'expand'=>true)
		patient_array = $dbAccess.getPatientArray
                patient_array.each{|i|
			list.insert('end', i)
		}
		list.yscrollbar(bar)
		TkButton.new($win) do
			text "Validate"
			command "$win.destroy"
			state "normal"
			cursor "watch"
			font TkFont.new('times 13 bold')
			grid('row'=>2, 'column'=>0)
		end

	}
	###########
	
	################# new Patient window
	newp_win=Proc.new{
	  $win = TkToplevel.new{ title "New Patient" }
		counter=1
		entry_map=Array.new
		TkLabel.new($win) {
		  text "Name"
		  font TkFont.new('times 12')
		  grid('row'=>0, 'column'=>0)
		}
		t0=TkEntry.new($win) {
		  grid('row'=>0, 'column'=>1)
		}
		
		TkButton.new($win) do
			command {
				v1 = TkVariable.new
				v2 = TkVariable.new
				t1=TkEntry.new($win) {
				  grid('row'=>counter, 'column'=>0)
				}
				t1.textvariable=v1
				v1.value="variable name"
				t2=TkEntry.new($win) {
				  grid('row'=>counter, 'column'=>1)
				}
				t2.textvariable=v2
				v2.value="value"
				entry_map.push([t1,t2])
				counter+=1
			}
			text "Add variable"
			state "normal"
			cursor "watch"
			font TkFont.new('times 12')
		        grid('row'=>30, 'column'=>0)
		end
		TkButton.new($win) do
			command{if t0.value!=""
					$dbAccess.addPatient(t0.value)
					entry_map.each  do |varname,value|
						$dbAccess.addVar(t0.value, varname.value, value.value)
					end
					$win.destroy
				else
					box= TkToplevel.new{ title "No name specified ! "}
					TkLabel.new(box) {
						text "     You must specify a name for the patient !     "
						foreground 'red'
						font TkFont.new('times 12')
						grid('row'=>0, 'column'=>0)
					}
				end
			}
			text "Validate"
			state "normal"
			cursor "watch"
			font TkFont.new('times 12')
		        grid('row'=>30, 'column'=>1)
		end

	}
	###########

	################# view Patient window
	view_win=Proc.new{
	  	$win = TkToplevel.new{ title "New Treatment"}
	
		TkLabel.new($win, "width"=>20) {
		  text "Patient: "
		  font TkFont.new('times 12 bold')
		  grid('row'=>0, 'column'=>0)
		}
		TkLabel.new($win, "width"=>20) {
		  text "Variables:"
		  font TkFont.new('times 12 bold')
		  grid('row'=>0, 'column'=>1)
		}
		index=1
		patient_array=$dbAccess.getPatientArray
		patient_array.each do |patientname|
			TkLabel.new($win, "width"=>20){
				text patientname
				compound 'center'
				grid('row'=>index, 'column'=>0)
			}
			String s=""
			$dbAccess.getPatientInfo(patientname).each do |var, val|
				s+=var+" = "+val+"\n"
			end
			TkLabel.new($win, "width"=>20){
				text s
				compound 'center'
				justify 'left'
				grid('row'=>index, 'column'=>1)
			}
			index+=1
		end

		TkButton.new($win) do
			command{$win.destroy}
			text "Validate"
			state "normal"
			cursor "watch"
			font TkFont.new('times 12')
			grid('row'=>index,'columnspan'=>2)
		end
	}
	###########


	#menu
	menu = TkMenu.new(root)

	menu.add('command',
		      'label'     => "New treatment",
		      'command'   => newt_win,
		      'underline' => 4)
	menu.add('command',
		      'label'     => "New patient profile",
		      'command'   => newp_win,
		      'underline' => 4)
	menu.add('command',
		      'label'     => "View patient profile",
		      'command'   => view_win,
		      'underline' => 2)
	menu.add('separator')
	menu.add('command',
		      'label'     => "Exit",
		      'command' => "exit",
		      'underline' => 0)

	menu_bar = TkMenu.new
	menu_bar.add('cascade',
		     'menu'  => menu,
		     'label' => "File")


	root.menu(menu_bar)


	Tk.mainloop
end

