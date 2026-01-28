extends Control


#==============================================================================#
# This is a simply settings menu for testing which allows for full running
# prototype without the need for presetting the car in editor,
# it provides basic parameters such as car selection, body mod options and
# color change for basic needs but more advanced settings require direct
# changes in the vehicles itself!
#==============================================================================#
# This menu can be a good example on how to make a working ingame menu for
# cars such as tune shops, carlot or any other menu that involves the car
#==============================================================================#
@export var veh_menu_list : Array[MVehicle3D] # Array where we can add more cars to

# This is to get the index of each dropdown button and assign it to specific setting
var vehicle : int = 0
var F_Bumper : int = 0
var R_Bumper : int = 0
var Hood : int = 0
var wheels : int = 0
var steering : int = 0
var veh_color : Color = Color(1.0, 1.0, 1.0, 1.0)

var identify_veh : MVehicle3D # Gets our picked car from array

func _ready() -> void:
	# Autogenerate list of driveable vehicles based on Array entries if any exist
	# This saves the hustle of constantly adding new entries in same order as they are in array
	var veh_list_button : OptionButton = $Cars # Assign correct Option Button for autogeneration
	if veh_menu_list.size() > 0 and veh_menu_list[vehicle] != null:
		for x in veh_menu_list.size():
			veh_list_button.add_item(veh_menu_list[x].veh_name, x)


func _select_veh_box(index: int) -> void:
	vehicle = index


func _on_hood_item_selected(index: int) -> void:
	Hood = index


func _on_rare_bumper_item_selected(index: int) -> void:
	R_Bumper = index


func _on_front_bumper_item_selected(index: int) -> void:
	F_Bumper = index


func _on_wheels_item_selected(index: int) -> void:
	wheels = index


func _on_steering_item_selected(index: int) -> void:
	steering = index


func _on_color_picker_button_color_changed(color: Color) -> void:
	veh_color = color

# Applies all changes to the vehicle we want to drive
func _run_game() -> void:
	if veh_menu_list.size() > 0 and veh_menu_list[vehicle] != null: # Safe check in case we forgot to add the cars
		identify_veh = veh_menu_list[vehicle] # Get our selected vehicle from list
		identify_veh.is_current_veh = true # Set it as driveable
	#region Applies all visual settings from menu directly to the car
		identify_veh.hood_mod = Hood
		identify_veh.front_bumper_mod = F_Bumper
		identify_veh.rare_bumper_mod = R_Bumper
		identify_veh.front_rim_id = wheels
		identify_veh.back_rim_id = wheels
		identify_veh.steering_model = steering
		identify_veh.veh_color = veh_color
	#endregion
		identify_veh.debug_hud = $CheckButton.button_pressed # Sets visible debug for the car
		identify_veh.assign_vehicle() # Triggers function that will assign us to our car and add all requred nodes
		self.queue_free() # Deletes this menu because we don't need it anymore
	else: # If we don't have car that we can select or array have null entries, print error
		return print_rich("[color=salmon][b]WARNING:[/b] There is no vehicle that player can be assigned to!")
