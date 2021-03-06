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
		@@vm=vm
		createGui(@@vm)
		@@dbAccess = DBAccess.new
		@vmid=0
		@@patient_concerned=""
		updateFrame
	end

	def createGui(vm)
			
		#Column of the main window
		
		br = ["Patient name", "Treatment", "Current task", "Conditions", "Buttons"].collect {|c|
		  	TkLabel.new(@frame1, "text"=>c, "borderwidth"=>5, "relief"=>"ridge", "width"=>20, 'font'=> TkFont.new('times 12 bold'))
		}
		TkGrid.grid(br[0], br[1], br[2], br[3], br[4])


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
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>0)
			}
			TkLabel.new(new_window) {
			  text "Patient"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
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
						@@dbAccess.updatePatient(plist.get(plist.curselection()[0]), tlist.get(tlist.curselection()[0]),Date.today.to_s)
						@@dbAccess.initPatientFluents(plist.get(plist.curselection()[0]), tlist.get(tlist.curselection()[0]))
						@@patient_concerned=plist.get(plist.curselection()[0])
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
			  width 20
			  font TkFont.new('times 12 bold')
			  grid('row'=>0, 'column'=>0)
			}
			t0=TkEntry.new(new_window) {
			  width 20
			  grid('row'=>0, 'column'=>1)
			}
			
			val_button=TkButton.new(new_window) do
				command{if t0.value==""
						box= TkToplevel.new{ title "No name specified ! "}
						TkLabel.new(box) {
							text "     You must specify a name for the patient !     "
							foreground 'red'
							font TkFont.new('times 12')
							grid('row'=>0, 'column'=>0)
						}
						TkButton.new(box) do
							command {box.destroy}
							text "ok"
							state "normal"
							cursor "watch"
							font TkFont.new('times 12')
							grid('row'=>1, 'column'=>0)
						end
					elsif
						@@dbAccess.getPatientArray.include?(t0.value)
						box= TkToplevel.new{ title "Patient name conflict ! "}
						TkLabel.new(box) {
							text "     Patient name already used, please choose another one!     "
							foreground 'red'
							font TkFont.new('times 12')
							grid('row'=>0, 'column'=>0)
						}
						TkButton.new(box) do
							command {box.destroy}
							text "ok"
							state "normal"
							cursor "watch"
							font TkFont.new('times 12')
							grid('row'=>1, 'column'=>0)
						end						
					else
						@@dbAccess.addPatient(t0.value)
						entry_map.each  do |variablename,value|
							if (not @@dbAccess.hasVariable(t0.value, variablename.value)) and (variablename.value != "variable name" and value.value != "value")
								@@dbAccess.addVariable(t0.value, variablename.value, value.value)
							end
						end
						new_window.destroy
					end
				}
				text "Validate"
				state "normal"
				cursor "watch"
				font TkFont.new('times 12')
				grid('row'=>counter, 'column'=>1)
			end
			add_button=TkButton.new(new_window) do
				command {

					v1 = TkVariable.new("variable name")
					v2 = TkVariable.new("value")
					t1=TkEntry.new(new_window) {
					  textvariable v1
					  width 20
					  grid('row'=>counter, 'column'=>0)
					}
					t2=TkEntry.new(new_window) {
					  textvariable v2
					  width 20
					  grid('row'=>counter, 'column'=>1)
					}
					entry_map.push([t1,t2])
					counter+=1
					add_button.grid('row'=>counter, 'column'=>0)
					val_button.grid('row'=>counter, 'column'=>1)
				}
				text "Add variable"
				state "normal"
				cursor "watch"
				font TkFont.new('times 12')
				grid('row'=>counter, 'column'=>0)
			end

		}
		###########

		################# view Patients window
		viewp_win=Proc.new{
		  	new_window = TkToplevel.new{ title "Patient profiles"}
	
			TkLabel.new(new_window, "width"=>20) {
			  text "Patient: "
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>0)
			}
			TkLabel.new(new_window, "width"=>20) {
			  text "Number of treatments:"
			  font TkFont.new('times 12 bold')
                          relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>1)
			}
			TkLabel.new(new_window, "width"=>20) {
			  text "Total duration:"
			  font TkFont.new('times 12 bold')
                          relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>2)
			}
			TkLabel.new(new_window, "width"=>20) {
			  text "Variables:"
			  font TkFont.new('times 12 bold')
                          relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>3)
			}
			TkLabel.new(new_window, "width"=>20) {
			  text "Fluents:"
			  font TkFont.new('times 12 bold')
                          relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>4)
			}
			TkLabel.new(new_window, "width"=>20) {
			  text "  "
			  font TkFont.new('times 12 bold')
                          
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>5)
			}
			index=1
			patient_array=@@dbAccess.getPatientArray
			patient_array.each do |patientname|
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text patientname
					compound 'center'
					grid('row'=>index, 'column'=>0)
				}
				l=@@dbAccess.getPatientTreatmentList(patientname)
				c="#{l.length} treatment(s) followed"
				if l.length > 0
					c+=":"
					l.each do |e|
						c+="\n #{e}"
					end 
				end
				@@dbAccess.getPatientTreatmentList(patientname)
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text c
					compound 'center'
					grid('row'=>index, 'column'=>1)
				}
				duration=@@dbAccess.getPatientDuration(patientname)
				duration_s=duration.to_s+" sec"
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text duration_s
					compound 'center'
					grid('row'=>index, 'column'=>2)
				}
				String s=""
				patient_var=@@dbAccess.getPatientVariables(patientname)
				patient_var.each do |var, val|
					s+=var+" = "+val+"\n"
				end
				if s==""
					s+="No Variable for that patient"
				end
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text s
					compound 'center'
					justify 'left'
					grid('row'=>index, 'column'=>3)
				}
				String f=""
				f=@@dbAccess.getPatientFluents(patientname)
				if f==""
					f+="No Fluent for that patient"
				end
				TkLabel.new(new_window, "width"=>20, "borderwidth"=>5){
					text f
					compound 'center'
					justify 'left'
					grid('row'=>index, 'column'=>4)
				}
				TkButton.new(new_window) do
					command{
						new_window.destroy
						update_window=TkToplevel.new{ title "Update profile of #{patientname} !"}
						TkLabel.new(update_window, "width"=>20) {
						  text "Variables: "
						  font TkFont.new('times 12 bold')
						  grid('row'=>0, 'column'=>0)
						}
						TkLabel.new(update_window, "width"=>20) {
						  text "Values:"
						  font TkFont.new('times 12 bold')
						  grid('row'=>0, 'column'=>1)
						}
						i=1
						modified_array=Array.new
						new_array=Array.new
						patient_var.each do |var, val| 
						var_label=TkLabel.new(update_window, "width"=>20, "borderwidth"=>5){
								text var
								grid('row'=>i, 'column'=>0)
							}
						v=TkVariable.new(val)
						val_entry=TkEntry.new(update_window, "width"=>20) {
								textvariable v
					  			grid('row'=>i, 'column'=>1)
							}
							modified_array.push([var, val, val_entry])
							i+=1
						end
						val_button=TkButton.new(update_window){
							command{
								modified_array.each do |var_name, old_value, value_widget|
									if value_widget.value!=old_value
										@@dbAccess.updateVariable(patientname, var_name, value_widget.value)
									end
								end
								new_array.each do |var_widget, val_widget|
									if (not @@dbAccess.hasVariable(patientname, var_widget.value)) and (var_widget.value != "variable name" and val_widget.value != "value")
										@@dbAccess.addVariable(patientname, var_widget.value, val_widget.value)
									end
								end
								update_window.destroy
							}
							text "Validate"
							grid('row'=>i,'column'=>1)
						}
						add_button=TkButton.new(update_window){
							command {
								v1 = TkVariable.new("variable name")
								v2 = TkVariable.new("value")
								var_entry=TkEntry.new(update_window) {
								  textvariable v1
								  grid('row'=>i, 'column'=>0)
								}
								val_entry=TkEntry.new(update_window) {
								  textvariable v2
								  grid('row'=>i, 'column'=>1)
								}
								new_array.push([var_entry, val_entry])
								i+=1
								add_button.grid('row'=>i,'column'=>0)
								val_button.grid('row'=>i,'column'=>1)
							}
							text "Add variable"
							grid('row'=>i,'column'=>0)
						}
											
					}
					text "Update profile"
					state "normal"
					cursor "watch"
					font TkFont.new('times 12')
					grid('row'=>index,'column'=>5)
				end
				index+=1
			end
		}
		###########

		################# view stats window
		viewt_win=Proc.new{
		  	new_window = TkToplevel.new{ title "Treatments and tasks stats"}

			TkLabel.new(new_window) {
			  text "Treatment: "
			  font TkFont.new('times 12 bold')
                          relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>0)
			}
			TkLabel.new(new_window) {
			  text "In progress:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 12
			  grid('row'=>0, 'column'=>1)
			}
			TkLabel.new(new_window) {
			  text "Finished:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 10
			  grid('row'=>0, 'column'=>2)
			}
			TkLabel.new(new_window) {
			  text "Treatment %:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 14
			  grid('row'=>0, 'column'=>3)
			}
			TkLabel.new(new_window) {
			  text "Mean time:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>4)
			}
			TkLabel.new(new_window) {
			  text "Tasks:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>5)
			}
			TkLabel.new(new_window) {
			  text "Mean time:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>6)
			}
			TkLabel.new(new_window) {
			  text "Variance:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>7)
			}
			TkLabel.new(new_window) {
			  text "Finished:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 10
			  grid('row'=>0, 'column'=>8)
			}
			TkLabel.new(new_window) {
			  text "Success %:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 10
			  grid('row'=>0, 'column'=>9)
			}
			TkLabel.new(new_window) {
			  text "Worst condition:"
			  font TkFont.new('times 12 bold')
			  relief "ridge"
			  borderwidth 5
			  width 20
			  grid('row'=>0, 'column'=>10)
			}
			row=1

			total_finished=0
			treatment_name_array=@@dbAccess.getTreatmentArray
			treatment_name_array.each{ |name|
				total_finished+=@@dbAccess.getTreatmentCounter(name)
			}
			
			treatment_name_array.each{ |treatment|

				TkLabel.new(new_window) {
				text treatment
				font TkFont.new('times 12')
				width 20
				grid('row'=>row, 'column'=>0)
				}

				number_in_progress=@@dbAccess.getTreatmentInProgress(treatment)
				TkLabel.new(new_window) {
				text number_in_progress.to_s
				font TkFont.new('times 12')
				width 12
				grid('row'=>row, 'column'=>1)
				}

				number_finished=@@dbAccess.getTreatmentCounter(treatment)
				TkLabel.new(new_window) {
				text number_finished.to_s
				font TkFont.new('times 12')
				width 10
				grid('row'=>row, 'column'=>2)
				}
				
				if total_finished>0
					percentage_finished=(number_finished*100/total_finished).round(2)
				else
					percentage_finished=0
				end
				TkLabel.new(new_window) {
				text percentage_finished.to_s+" %"
				font TkFont.new('times 12')
				width 14
				grid('row'=>row, 'column'=>3)
				}

				duration=@@dbAccess.getTreatmentDuration(treatment)
				if number_finished>0
					mean=(duration/number_finished).round(2)
				else
					mean=0
				end
				TkLabel.new(new_window) {
				text mean.to_s+" s"
				font TkFont.new('times 12')
				width 20
				grid('row'=>row, 'column'=>4)
				}
				
				tasks_array=@@dbAccess.getTasksFromTreatment(treatment)
				name_s=""
				mean_s=""
				variance_s=""
				finished_s=""
				success_s=""
				conditions_s=""
				tasks_array.each{ |task|
					name_s+=task+"\n"
					
					stats=@@dbAccess.getTaskStats(task, treatment)
					mean_s+=stats[0].to_s+" sec \n"
					variance_s+=stats[1].to_s+" \n"

					task_finished=@@dbAccess.getTaskFinishedNumber(task, treatment)
					finished_s+=task_finished.to_s+" \n"

					success_percentage=@@dbAccess.getSuccessPercentage(task, treatment)
					success_s+=success_percentage.to_s+" \n"

					condition_f=@@dbAccess.getMostConditionFailure(task, treatment)
					conditions_s+=condition_f.to_s+" \n"
				}
								
				TkLabel.new(new_window) {
				text name_s
				font TkFont.new('times 12')
				width 20
				grid('row'=>row, 'column'=>5)
				}
				
				
				TkLabel.new(new_window) {
				text mean_s
				font TkFont.new('times 12')
				width 20
				grid('row'=>row, 'column'=>6)
				}
				TkLabel.new(new_window) {
				text variance_s
				font TkFont.new('times 12')
				width 20
				grid('row'=>row, 'column'=>7)
				}

				
				TkLabel.new(new_window) {
				text finished_s
				font TkFont.new('times 12')
				width 10
				grid('row'=>row, 'column'=>8)
				}

				
				TkLabel.new(new_window) {
				text success_s
				font TkFont.new('times 12')
				width 10
				grid('row'=>row, 'column'=>9)
				}

				
				TkLabel.new(new_window) {
				text conditions_s
				font TkFont.new('times 12')
				width 20
				grid('row'=>row, 'column'=>10)
				}

				
				
				
			row+=1
			}

		
		}
		###########

		#menu
		menu = TkMenu.new(@root)

		menu.add('command',
			      'label'     => "New treatment",
			      'command'   => newt_win)
		menu.add('command',
			      'label'     => "New patient",
			      'command'   => newp_win)
		menu.add('command',
			      'label'     => "View patients profile",
			      'command'   => viewp_win
				)
		menu.add('command',
			      'label'     => "Tasks info",
			      'command'   => viewt_win
			)
		menu.add('separator')
		menu.add('command',
			      'label'     => "Exit",
			      'command' => Proc.new{vm.stop})

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
		color="white"
		line=data_map.each{|vmid, patient, treatment, task|
			
			if @@dbAccess.isStarted(vmid)
				tlabel="start"
			else
				tlabel="stop"
			end
			conditions=@@dbAccess.getCondition(task,treatment)
			conditions_s=""
			if conditions!=""
				conditions.split(",").each {|e| conditions_s+=e.lstrip+"\n"}
			end
			p=TkLabel.new(@frame2, "text"=>patient, "borderwidth"=>5, "width"=>20)
			t=TkLabel.new(@frame2, "text"=>treatment, "borderwidth"=>5, "width"=>20)
			ta=TkLabel.new(@frame2, "text"=>task, "borderwidth"=>5, "width"=>20)
			w=TkLabel.new(@frame2, "text"=>conditions_s, "borderwidth"=>5, "width"=>20)
			b=TkButton.new() do
				text tlabel
				state "normal"
				cursor "watch"
				font TkFont.new('times 12')
				width 15
				command {
					 if tlabel=="start"
						@@dbAccess.updatetasktime(vmid, :starttime)
						wrong=@@dbAccess.checkCondition(vmid, task, treatment, patient)
						if wrong[0] != "" or wrong[1] !=""
							box= TkToplevel.new{ title "Condition(s) not respected!"}
							TkLabel.new(box) {
								text "Patient doesn't have corresponding variable : "
								font TkFont.new('times 12')
								grid('row'=>0, 'column'=>0)
							}
							if wrong[0]==""
								wrong[0]="/"
							end
							TkLabel.new(box) {
								text wrong[0]
								font TkFont.new('times 12')
								grid('row'=>0, 'column'=>1)
							}
							if wrong[1]==""
								wrong[1]="/"
							end
							TkLabel.new(box) {
								text "Value doesn't respect the condition : "
								font TkFont.new('times 12')
								grid('row'=>1, 'column'=>0)
							}
							TkLabel.new(box) {
								text wrong[1]
								font TkFont.new('times 12')
								grid('row'=>1, 'column'=>1)
							}
							TkButton.new(box) do
							command {box.destroy}
							text "ok"
							state "normal"
							cursor "watch"
							font TkFont.new('times 12')
							grid('row'=>2, 'column'=>0)
						end
						end
						tlabel="stop"
						b.text(tlabel)
					 else
						@@dbAccess.updatetasktime(vmid, :endtime)
						@@patient_concerned=patient
						@@dbAccess.updateFluentsPatient(patient, task)
						box= TkToplevel.new{ title "Task ended!"}
						TkLabel.new(box) {
							text "Time needed : "
							font TkFont.new('times 12')
							grid('row'=>0, 'column'=>0)
						}
						TkLabel.new(box) {
							text @@dbAccess.getDuration(vmid)
							font TkFont.new('times 12')
							grid('row'=>0, 'column'=>1)
						}
						TkLabel.new(box) {
							text "Mean time for this task : "
							font TkFont.new('times 12')
							grid('row'=>1, 'column'=>0)
						}
						TkLabel.new(box) {
							text @@dbAccess.getMean(task, treatment)
							font TkFont.new('times 12')
							grid('row'=>1, 'column'=>1)
						}
						TkLabel.new(box) {
							text "Not respected condition(s) : "
							font TkFont.new('times 12')
							grid('row'=>3, 'column'=>0)
						}
						TkLabel.new(box) {
							text @@dbAccess.getConditionsFailure(vmid)
							font TkFont.new('times 12')
							grid('row'=>3, 'column'=>1)
						}
						TkLabel.new(box) {
							text "fluents : "
							font TkFont.new('times 12')
							grid('row'=>4, 'column'=>0)
						}
						TkLabel.new(box) {
							text @@dbAccess.getPatientFluents(patient)
							font TkFont.new('times 12')
							grid('row'=>4, 'column'=>1)
						}
						TkButton.new(box) do
							command {box.destroy}
							text "ok"
							state "normal"
							cursor "watch"
							font TkFont.new('times 12')
							grid('row'=>5, 'column'=>0)
						end
						@@vm.resume(vmid,[:ended])
					 end
				}
			end

			TkGrid.grid(p,t,ta,w,b)

			bool=!bool
		}

	end
	
	
	def createTaskInstance(id, task_name)
		@vmid=id
		treatment=@@dbAccess.getPatientTreatment(@@patient_concerned)
		@@dbAccess.addTaskInstance(@vmid, @@patient_concerned, task_name, treatment)
		updateFrame		
	end
	
	def endTreatment
		treatment=@@dbAccess.getPatientTreatment(@@patient_concerned)
		@@dbAccess.incrementTreatmentCounter(treatment)
		@@dbAccess.deletePatientFluents(@@patient_concerned)
		@@dbAccess.updatePatient(@@patient_concerned,"","")
	end

end

