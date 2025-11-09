@icon("res://addons/M.A.V.S/Textures/MTrafficSpawner.png") # Icon by: edt.im Downloaded from Flaticon, Recolored by Millu30
extends Node3D


## Spawner node for cars, handles vehicle AI properties and generates cars and add them to specific paths
class_name MTrafficSpawner

@export var allow_despawn : bool = false # Allows cars to despawn overtime
@export_range(0.05, 360.0) var time_interval : float = 3.0 # Time in seconds between each spawn of the car
@export_range(-1, 50) var spawn_limiter : int = -1 # Limits spawning to certain point -1 means no limits
@export var generation_distance : float = 30.0 # Is the distance between player car and spawner in which spawner will be allowed to generate traffic
@export var vehicle_pool : Resource # List of all the cars that can be spawned by our Traffic Spawner
@export var traffic_manager : PackedScene # Scene of our Traffic target
@export var check_area : Area3D # Area that detects if there is any car in it
@export var arrow_remove : Node3D # Node that will be removed when running the scene
@export var time_counter : Timer # Reference to our time node soo we can edit it when placing the node on the map instead of editing the full node itself
@export var road_line : Path3D # Reference to our road where our target will be spawned
var vehicle_target : PackedScene # Loaded reference to our Traffic Manager node
var vehicle_list : Array # Reference to loaded Vehicle list
var spawn_count : int = 0 # How much cars have been spawned already


func _ready() -> void:
	
	if !Performance.has_custom_monitor("Traffic System/Traffic Target Count"): # Checks if we have Monitor in Debugger
		Performance.add_custom_monitor("Traffic System/Traffic Target Count", traffic_counter) # Adds Monitor at the bottom of Debbuger
	arrow_remove.queue_free() # Removes first child which is Arrow and Icon when loaded on the map, its to make it easier to work in editor
	time_counter.start(time_interval) # Sets our timer to the defined intervals, easier to edit it through root node rather than editing it in scene itself and more felxible
	if vehicle_pool is Resource: # Checks if we have resource assigned to our variable, it prevents from crashing in case we forgot to add one
		var new_pool_list = load(vehicle_pool.resource_path).new() # Adds our vehicle variable from which we can take from
		vehicle_list = new_pool_list.veh_list # Puts array of our cars into out variable
		vehicle_target = load(traffic_manager.resource_path) # Loads our Traffic Target
		
func _on_timer_timeout() -> void:
	var distance # Distance variable for future reference
	var player_nodes = get_tree().get_nodes_in_group("Player_car") # Gets reference to any node in Player_car group
	if player_nodes.size() > 0: # Checks if there are any players in Player_car Group
		var player_car = player_nodes[0]  # get the first player
		distance = self.global_position.distance_to(player_car.global_position) # Calculates distance between player car and itself
		
		
	if distance < generation_distance: # Checks if we are close enough to the spawner
		if road_line != null: # Checks if we actually have put any lines for road
			if check_area.has_overlapping_bodies() == false: # Checks if there are any bodies on the spawner location. "Prevents from spawning cars on other cars"

				if spawn_limiter == -1: # If we have a -1 limiter set then there should be no limits for spawning cars
					set_cars_for_spawn()
				elif spawn_count < spawn_limiter: # If amount of spawned cars is lower than limiter then spawn cars
					set_cars_for_spawn()
					spawn_count += 1 # Add one to self counter when spawning vehicle
		else: print("No road has been assigned, nothing will be spawned!")


# Moved this from _on_timer_timeout() to prevent memory leaking by instantiating objects that will never be spawned
func set_cars_for_spawn() -> void:
	var target = vehicle_target.instantiate() # Instantiate target for our traffic car
	var select_car : PackedScene = load(vehicle_list.pick_random()) # Loads our randomly picked car
	var selected_car = select_car.instantiate() # Instantiate the car
	selected_car.global_transform = self.global_transform # Places our traffc on the spawner location
	selected_car.take_speed_from_target = true # Sets option for our car to take speed from its target
	selected_car.boost_speed = true # Sets speed booster for better traffic flow
	selected_car.target_ray = target # Sets target to our car to follow it
	target.target_veh = selected_car # Sets target car for our Target
	selected_car.despawn_allowed = allow_despawn
	target.add_to_group("Traffic") # We set our cars to a traffic group same goes with their targets
	selected_car.add_to_group("Traffic")
	self.get_parent().add_child(selected_car) # Adds New traffic car to our map
	road_line.add_child(target) # Adds new traffic target to our road


func traffic_counter() -> int: # Shows in Debugger how many cars are on the map
	return get_tree().get_nodes_in_group("Traffic_Spawner").size()
