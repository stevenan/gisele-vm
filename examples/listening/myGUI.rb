require 'tk'
require_relative 'dbAccess'

class MyGUI

	def initialize(vm)
		@root = TkRoot.new do
		  minsize(200,200)
		  title "Main"
		  resizable 0,0
		end
		@frame1 = TkFrame.new(@root) {pack('padx'=>0, 'pady'=>0,  'fill'=>'x')}
		@frame2 = TkFrame.new(@root){pack('padx'=>0, 'pady'=>0,  'fill'=>'x', 'fill'=>'y')}
		createGui(vm)
		@@dbAccess = DBAccess.new
		@vmid=0
		@@patient_concerned=""
		updateFrame
	end

	def createGui(vm)
			
		#Column of the main window
		
		br = ["Patient name", "Treatment", "Current task", "Warning", "Buttons"].collect {|c|
		  	TkLabel.new(@frame1, "text"=>c, "borderwidth"=>5, "relief"=>"ridge", "width"=>20)
		}
		TkGrid.grid(br[0], br[1], br[2], br[3], br[4])


		#Lines to separate data
		s0 = Tk::Tile::Separator.new(@root) do
		   orient 'vertical'
		   place('height' => 180, 'x' => 172, 'y' => 30)
		end
		s1 = Tk::Tile::Separator.new(@root) do
		   orient 'vertical'
		   place('height' => 180, 'x' => 344, 'y' => 30)
		end
		s2 = Tk::Tile::Separator.new(@root) do
		   orient 'vertical'
		   place('height' => 180, 'x' => 516, 'y' => 30)
		end
		s3 = Tk::Tile::Separator.new(@root) do
		   orient 'vertical'
		   place('height' => 180, 'x' => 688, 'y' => 30)
		end


		#window generated from menu
		newTreatment_proc = Proc.new {
		  TkToplevel.new(@root){
		    title "New Treatment"
		  }
		}
		newPatient_proc = Proc.new {
		  TkToplevel.new(@root){
		    title "New Treatment"
		  }
		}

		################# new Treatment window
		newt_win=Proc.new{
		  new_window = TkToplevel.new{ title "New Treatment" }
			TkLabel.new(new_window) {
			  text "Treatment"
			  font TkFont.new('times 12 bold')
			  grid('row'=>0, 'column'=>0)
			}
			TkLabel.new(new_window) {
			  text "Patient"
			    font TkFont.new('times 12 bold')
			  grid('row'=>0, 'column'=>1)
			}

			f1 = TkFrame.new(new_window) {
			  padx 15
			  pady 20
			  grid('row'=>1, 'column'=>0)
			}
			tbar = TkScrollbar.new(f1) do
				pack('side'=>'right', 'fill'=>'y')
			end
			tlist = TkListbox.new(f1) do
				selectmode 'single'
				exportselection '0'
				pack('side'=>'left', 'fill'=>'both', 'expand'=>true)
			end
			treatment_array = @@dbAccess.getTreatmentArray
		        treatment_array.each{|i|
				tlist.insert('end', i)
			}
			tlist.yscrollbar(tbar)
			f2 = TkFrame.new(new_window) {
			  padx 15
			  pady 20
			  grid('row'=>1, 'column'=>1)
			}
			pbar = TkScrollbar.new(f2).pack('side'=>'right', 'fill'=>'y')
			plist = TkListbox.new(f2) do			
				exportselection '0'
				selectmode 'single'
				pack('side'=>'left', 'fill'=>'both', 'expand'=>true)
			end
			patient_array = @@dbAccess.getAvailablePatientArray
		        patient_array.each{|i|
				plist.insert('end', i)
			}
			plist.yscrollbar(pbar)
			TkButton.new(new_window) do
				text "Validate"
				command {
					if (not (plist.curselection()).empty?) && (not (tlist.curselection()).empty?)
						@@dbAccess.updatePatient(plist.get(plist.curselection()[0]), tlist.get(tlist.curselection()[0]))
						@@patient_concerned=plist.get(plist.curselection()[0])
						puts "ici on a le patient #{@@patient_concerned}"
						vm.start(:main, [ tlist.get(tlist.curselection()[0]).strip.to_sym])
						new_window.destroy
					end
				}
				state "normal"
				cursor "watch"
				font TkFont.new('times 13 bold')
				grid('row'=>2, 'column'=>0)
			end

		}
		###########
	
		################# new Patient window
		newp_win=Proc.new{
		  new_window = TkToplevel.new{ title "New Patient" }
			counter=1
			entry_map=Array.new
			TkLabel.new(new_window) {
			  text "Name"
			  font TkFont.new('times 12')
			  grid('row'=>0, 'column'=>0)
			}
			t0=TkEntry.new(new_window) {
			  grid('row'=>0, 'column'=>1)
			}
		
			TkButton.new(new_window) do
				command {

					v1 = TkVariable.new
					v2 = TkVariable.new
					t1=TkEntry.new(new_window) {
					  grid('row'=>counter, 'column'=>0)
					}
					t1.textvariable=v1
					v1.value="variable name"
					t2=TkEntry.new(new_window) {
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
			TkButton.new(new_window) do
				command{if t0.value==""
						box= TkToplevel.new{ title "No name specified ! "}
						TkLabel.new(box) {
							text "     You must specify a name for the patient !     "
							foreground 'red'
							font TkFont.new('times 12')
							grid('row'=>0, 'column'=>0)
						}
					elsif
						@@dbAccess.getPatientArray.include?(t0.value)
						box= TkToplevel.new{ title "Patient name conflict ! "}
						TkLabel.new(box) {
							text "     Patient name already used, please choose another one!     "
							foreground 'red'
							font TkFont.new('times 12')
							grid('row'=>0, 'column'=>0)
						}
						
					else
						@@dbAccess.addPatient(t0.value)
						entry_map.each  do |fluentname,value|
							@@dbAccess.addFluent(t0.value, fluentname.value, value.value)
						end
						new_window.destroy
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
		  	new_window = TkToplevel.new{ title "New Treatment"}
	
			TkLabel.new(new_window, "width"=>20) {
			  text "Patient: "
			  font TkFont.new('times 12 bold')
			  grid('row'=>0, 'column'=>0)
			}
			TkLabel.new(new_window, "width"=>20) {
			  text "Variables:"
			  font TkFont.new('times 12 bold')
			  grid('row'=>0, 'column'=>1)
			}
			index=1
			patient_array=@@dbAccess.getPatientArray
			patient_array.each do |patientname|
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text patientname
					compound 'center'
					grid('row'=>index, 'column'=>0)
				}
				String s=""
				@@dbAccess.getPatientFluents(patientname).each do |var, val|
					s+=var+" = "+val+"\n"
				end
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text s
					compound 'center'
					justify 'left'
					grid('row'=>index, 'column'=>1)
				}
				index+=1
			end

			TkButton.new(new_window) do
				command{new_window.destroy}
				text "Validate"
				state "normal"
				cursor "watch"
				font TkFont.new('times 12')
				grid('row'=>index,'columnspan'=>2)
			end
		}
		###########
		test=Proc.new{
			input = :ended.map{|x| Bytecode::Grammar.parse(x, :root => :arg).value}
			vm.resume(2,input)
		}

		#menu
		menu = TkMenu.new(@root)

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
			      'command' => test,
			      'underline' => 0)

		menu_bar = TkMenu.new
		menu_bar.add('cascade',
			     'menu'  => menu,
			     'label' => "File")


		@root.menu(menu_bar)
		Thread.new { Tk.mainloop }
	end

	def updateFrame
		@frame2.unpack
		@frame2 = TkFrame.new(@root){pack('padx'=>0, 'pady'=>0,  'fill'=>'x', 'fill'=>'y')}
		data_map=@@dbAccess.getTaskInstances
		color_boolean=true
		line=data_map.each{|vmid, patient, treatment, task|
			tlabel="start"
			if color_boolean
				color="white"
			else
				color="grey"
			end
			p=TkLabel.new(@frame2, "text"=>patient, "borderwidth"=>5, "width"=>20, "background"=>color)
			t=TkLabel.new(@frame2, "text"=>treatment, "borderwidth"=>5, "width"=>20, "background"=>color)
			ta=TkLabel.new(@frame2, "text"=>task, "borderwidth"=>5, "width"=>20, "background"=>color)
			w=TkLabel.new(@frame2, "text"=>"", "borderwidth"=>5, "width"=>20, "background"=>color)
			b=TkButton.new() do
				text tlabel
				state "normal"
				cursor "watch"
				font TkFont.new('times 12')
				background color
				width 7
				command {
					 if tlabel=="start"
						puts "start #{vmid}"
						@@dbAccess.updatetasktime(vmid, :starttime)
					 else
						puts "stop #{vmid}"
						@@dbAccess.updatetasktime(vmid, :endtime)
					 end
					 tlabel="stop"
					 b.text(tlabel)
				}
			end

			b1=TkButton.new() do
				text "info"
				state "normal"
				cursor "watch"
				font TkFont.new('times 12')
				background color
				width 7
			end

			TkGrid.grid(p,t,ta,w,b,b1)

			bool=!bool
		}

	end
	
	
	def createTaskInstance(id, task_name)
		@vmid=id
		treatment=@@dbAccess.getPatientTreatment(@@patient_concerned)
		puts "id = #{id}"
		puts "task = #{task_name}"
		puts "treatment = #{treatment}"
		puts "patient_concerned = #{@@patient_concerned}"
		@@dbAccess.addTaskInstance(@vmid, @@patient_concerned, task_name, treatment)
		updateFrame		
	end

end

