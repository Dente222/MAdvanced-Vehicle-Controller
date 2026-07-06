extends Node3D

@export var spawn_location : Vector3 # Coordinates where we want our car to spawn
@export_range(0, 360) var spawn_direction : float # Direction to which we want our car to face

# Basic settings to spawn vehicle on the map with all changes taken from menu
# From here we pass few additional informations for our function to properly
# deploy our vehicle on the map

func _ready() -> void:
	var map_root : Node3D = self # Root node to which we want to spawn our car "TestMap"
	# We pass our arguments and trigger the function which will spawn our vehicle
	# with all the changes we have provided
	# While this function is contained in our vehicle_list class, we don't need
	# to autoload it or reference it or make it global, simple calling its call
	# will allow us to use it :)
	player_spawn_vehicle_list.spawn_player_vehicle(spawn_location, spawn_direction, map_root)
