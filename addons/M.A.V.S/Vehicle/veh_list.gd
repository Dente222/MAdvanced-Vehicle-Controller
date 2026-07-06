extends RefCounted
class_name player_spawn_vehicle_list # Class name, better to have it long and unique so we don't mix stuff up

# List of available cars in main menu, its been turned into class soo we can acces it without
# referencing it anywhere
static var veh_listing: Array[String] = [
	"res://addons/M.A.V.S/Vehicle/Cleo V8/CleoV8.tscn",
	"res://addons/M.A.V.S/Vehicle/GT30/GT30.tscn",
	"res://addons/M.A.V.S/Vehicle/TGR/TRG.tscn",
	"res://addons/M.A.V.S/Vehicle/Muscle/Muscle Car.tscn",
	"res://addons/M.A.V.S/Vehicle/NightSky/NightSky_Body.tscn",
	"res://addons/M.A.V.S/Vehicle/Trucks/Gharial/Gharial_Truck.tscn"
]

# Basic informations we want to get from main menu before switching to another map
static var vehicle : PackedScene # Stores our selected vehicle as PackedScene
static var hood : int # Stores ID of the hood
static var f_bumper : int # Stores ID of Front Bumper
static var r_bumper : int # Stores ID of Rare Bumper
static var color : Color # Stores Colour of the vehicle


# This function spawns our vehicle on the map, it has to be triggered by the
# map itself on ready() function or any other function user desires
# NOTE: This function can only be triggered by the map we want to spawn vehicle on
# If we try to spawn it from Main menu after changing scene, we will get crash due to
# function trying to spawn vehicle in a void between scenes mostly because our map
# have not been loaded yet, thats why we trigger this from another map :)

static func spawn_player_vehicle(spawn_location : Vector3, spawn_direction : float, map_root : Node3D) -> void:
	var car = vehicle.instantiate() as MVehicle3D # Reference and instantiation of our PackedScene vehicle as MVehicle3D
	car.is_current_veh = true # We set this vehicle as a current one to allow us to drive
	car.debug_hud = true # Opens Debug Hud by default for every vehicle
	car.veh_state = car.state.DRIVE # Changes car state to driving
	car.hood_mod = hood # We apply our Hood mod ID to the vehicle
	car.front_bumper_mod = f_bumper # Apply Front Bumper Mod ID to the vehicle
	car.rare_bumper_mod = r_bumper # Apply Rare Bumper Mod ID to the vehicle
	car.veh_color = color # Set the colour of our vehicle
	map_root.add_child(car) # We spawn the vehicle to our map first node
	car.global_position = spawn_location # We set the position where vehicle will be spawned
	car.global_rotation = Vector3(0, deg_to_rad(spawn_direction), 0) # We set direction which it will face
	if car.veh_name == "Gharial Truck": # Check if we are using Truck then adjust camera settings
		car.is_truck = true
	if car.mod_list: # Check if car have list of mods, prevents crashes from vehicles that dont use mods
		# Here we remove parts to prevent duplication, we also do that because our vehicle have
		# adds parts when it gets spawned soo we need to remove default ones and add new ones
		car.hood_location.get_child(0).free()
		car.front_bumper_location.get_child(0).free()
		car.rare_bumper_location.get_child(0).free()
		
		# After we remove all default parts, we can now re-add new parts based on our part ID's
		car.update_hood()
		car.update_f_bumper()
		car.update_r_bumper()
		
	# We check here if our vehicle can be painted and if soo change its colour
	if car.allow_color_change:
		car.switch_color(color)
