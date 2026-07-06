extends Node3D

@export var map : PackedScene # Scene to the next map that we want to spawn our vehicle and drive around
@export var camera_arm : Node3D # Reference to our platform
@export var menu_UI : Control # Reference to main UI node of the scene
@export var menu_arrows : Control # Reference to Arrows in menu
@export var veh_label : Label # Numbers of vehicles that are available
@export var veh_name_label : Label # Label that displays vehicle name
@export var menu_list : Array[Control] # List of all menues
@export var main_menu_screen : Control # Stores main menu
@export var main_button : Button # Reference to main menu button used to open sub menues
@export var colour_menu : ColorPickerButton # Colour picker for colour menu

var menu_veh : MVehicle3D # Reference to displayed vehicle
var vehicle_scenes : Array[PackedScene] # Contains Array of all cars that can spawn and keeps them as PackedScene for easy load
var rotate_input : float = 0.0 # Set Rotation of input
const rotation_speed : float = 0.01 # Rotation radians per second
var menu_vehicle : int # ID of the spawned vehicle
var menu_state : int = 0 # Sets menues to zero state
var current_menu : String = "main" # Menu States for easire management
var main_option : int = 0 # Number for Arrow buttons to switch between menus and options
var veh_color : Color # Store Color of the car to update color picker and vehicle color
const location : Vector3 = Vector3(0, 0.65, 0) # Location where to place our car
var force_neutral : bool = false # Forces vehicle into neutral gear, usefull for intro's and garage

func _ready() -> void: # Initiates some basic stuff on loading scene
	main_menu_screen.get_child(0).grab_focus()
	for v in player_spawn_vehicle_list.veh_listing: # Loops through all the cars from the list
		vehicle_scenes.append(load(v)) # Loads all cars to the variable
	menu_vehicle = randi_range(0, vehicle_scenes.size() - 1) # Selects Random car from the list
	menu_veh = vehicle_scenes[menu_vehicle].instantiate() as MVehicle3D # Instantiates random menu vehicle as MVehicle3D
	self.add_child(menu_veh) # Spawns Vehicle
	menu_veh.global_position = location
	
	veh_color = menu_veh.veh_color # Takes colour from the car to prevent bugs with changing mods
	match current_menu: # Hides all submenues in case
		"main":
			menu_list[0].hide()
			menu_list[1].hide()
			menu_list[2].hide()
	
func _process(delta: float) -> void: 
	rotate_input = lerp(rotate_input, Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), 0.1) # Makes platform rotate with right analogue
	camera_arm.global_rotate(Vector3.UP, rotate_input * rotation_speed) # Rotation speed of the platform
	veh_label.text = "%d / %d" % [menu_vehicle + 1, player_spawn_vehicle_list.veh_listing.size()] # Updates the number in Carlot menu that displays current vehicle from how many
	if menu_list[main_option].name: # Displays name of the option on the button based on Menu List Array entries
		main_button.text = menu_list[main_option].name

func select_option() -> void:
	match main_option:
		0:
			menu_list[0].show()
			main_menu_screen.hide()
			menu_arrows.get_child(0).grab_focus()
			current_menu = "carlot"
			veh_name_label.text = menu_veh.veh_name # Loads name of the vehicle when Carlot is open
		1:
			if menu_veh.mod_list != null: # Checks if vehicle have list of mods available
				main_menu_screen.hide()
				menu_list[1].show()
				menu_arrows.hide()
				menu_list[1].get_child(0).grab_focus()
				current_menu = "tuning"
			else:
				print("Vehicle don't have any customizations!")
		2:
			main_menu_screen.hide()
			menu_arrows.hide()
			menu_list[2].show()
			menu_list[2].get_child(0).grab_focus()
			current_menu = "paintshop"
			colour_menu.color = menu_veh.veh_color # Changes colour in colour selection box
			
	print(current_menu)
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # Goes back to the main menu state
		main_menu_screen.show() # Shows main menu
		main_menu_screen.get_child(0).grab_focus()
		current_menu = "main" # Changes state of the menu then hides other sub menues
		menu_arrows.show()
		menu_list[0].hide()
		menu_list[1].hide()
		menu_list[2].hide()
		print(current_menu)


# This one increments the value for each menu/submenu based on which is currently open
func Increase_number() -> void:
	match current_menu:
		"main":
			main_option += 1
			if main_option >= menu_list.size():
				main_option = 0
				
		"carlot":
			if menu_vehicle < player_spawn_vehicle_list.veh_listing.size() -1: # Prevents from having value higher than the amount of cars we have
				menu_vehicle += 1
				_switch_vehicle() # Switches vehicle when changing in carlot
	print(main_option)

# Sane as above but when value is decreased
func Decrease_number() -> void:
	match current_menu:
		"main":
			main_option -= 1
			if main_option < 0:
				main_option = (menu_list.size() - 1)
		"carlot":
			if menu_vehicle > 0: # Stops us from having negative value
				menu_vehicle -= 1
				_switch_vehicle() # Switches vehicle when changing in carlot
	print(main_option)

# Function that changes the vehicle in menu
func _switch_vehicle() -> void:
	menu_veh.queue_free() # Remove current vehicle
	menu_veh = vehicle_scenes[menu_vehicle].instantiate() as MVehicle3D # Select new vehicle based on its position in array
	self.add_child(menu_veh) # Spawn new vehicle
	menu_veh.global_position = location
	veh_name_label.text = menu_veh.veh_name # Display vehicle name
	veh_color = menu_veh.veh_color # Set vehicle colour in colour picker

# Function to handle colour changes
func _on_color_picker_button_color_changed(color: Color) -> void:
	veh_color = color # Sets colour for current vehicle based on colour picker
	if menu_veh.allow_color_change: # Checks if vehicle can actually have its colour changed
		menu_veh.veh_color = color
		menu_veh.switch_color(veh_color) # Pass the colour value to our spawned vehicle and paint it

# Below we have logic for each vehicle custom part, only aplicable to Cleo V8 since its the only vehicle with customizations
# The logic for adding vehicle parts has been rewriten to work with custom menues easily
# Function that updates vehicle hood
func _on_hood_button_item_selected(index: int) -> void:
	menu_veh.hood_mod = index # Select index tab and pass it to the vehicle so it can pick correct part
	menu_veh.hood_location.get_child(0).free() # Remove currently attached part
	menu_veh.update_hood() # Add add parts again but with updated index
	menu_veh.switch_color(veh_color) # Apply colour to match vehicle colour
	
# Function that updates vehicle front bumper
func _on_front_bumper_item_selected(index: int) -> void:
	menu_veh.front_bumper_mod = index
	menu_veh.front_bumper_location.get_child(0).free()
	menu_veh.update_f_bumper()
	menu_veh.switch_color(veh_color)

# Function that updates vehicle rare bumper
func _on_rare_bumper_item_selected(index: int) -> void:
	menu_veh.rare_bumper_mod = index
	menu_veh.rare_bumper_location.get_child(0).free()
	menu_veh.update_r_bumper()
	menu_veh.switch_color(veh_color)

# Changes map and applies every needed changes to the vehicle that we will spawn on the next map
func _change_map() -> void:
	player_spawn_vehicle_list.vehicle = vehicle_scenes[menu_vehicle] # Sets our vehicle for the map
	player_spawn_vehicle_list.hood = menu_veh.hood_mod # Set ID for Hood mod
	player_spawn_vehicle_list.f_bumper = menu_veh.front_bumper_mod # Set ID for Front Bumper
	player_spawn_vehicle_list.r_bumper = menu_veh.rare_bumper_mod # Set ID for Rare Bumper
	player_spawn_vehicle_list.color = veh_color # Set colour for our vehicle
	get_tree().change_scene_to_packed(map) # Changes map 
