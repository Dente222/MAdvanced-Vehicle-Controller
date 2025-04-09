@icon("res://Advanced Vehicle Controller/Textures/MVehicleBody3DAI.png")
extends VehicleBody3D

class_name MVehicle_AI_NaviRegion # Class so it is easier to find in Add Child Node window :)

## AI Based on NavigationMesh3D and NavigationAgent3D, It has its own pathfinding which makes it
## viable to be used as a traffic or on race tracks

#////////////////////////////////////////////////////////////////////////////////////////////////#
# This is where we set up our Vehicle AI based on NavigationRegion3D node, our vehicle should
# generate a path to the target and follow its generated points by default, note that this can be
# pottentially applied to PathFollow3D for constantly moving target but might require more micro
# management to prevent vehicle from taking the shortcuts or deadend routs.
# NOTE: This is sort of barebone AI and it does not have logic to reverse and avoid obstacles
# properly, however, it is planed to add contex steering to it so it will reverse and avoid
# obstacles in more efficient way, but it is still better than Follow AI since it does move
# on a defined are and will try to avoid walls and clifs if possible.
# Copyright 2025 Millu30 A.K.A Gidan
#////////////////////////////////////////////////////////////////////////////////////////////////#

@export_category("AI Settings")
@export_group("AI")
@export var enable_debug : bool = false # This will display debug info like AI path and Vehicle coordinations
@export var max_speed : float = 50.0 # Max power this car will receive
@export var max_rev_speed : float = -1500.0
@export var nav : NavigationAgent3D # Definition for our navigation agent
@export var target_ray : Node3D # Definition for nodes we want our AI to generate path to
@export_range(1.0, 45.0) var steering_sensitivity: float = 40.0 # Max angle our car cant turn its wheels

@export_group("Context steering")
@export var front_rc : RayCast3D # Checks if there is something in front of the car 
@export var back_rc : RayCast3D # Raycast for context steering WIP!!!
@export var left_lite_rc : RayCast3D # Raycast for context steering WIP!!!
@export var right_lite_rc : RayCast3D # Raycast for context steering WIP!!!

@export_category("Vehicle Settings")
@export_group("Energy")
@export var use_energy : bool = false
@export var max_energy : float = 150.0 # Max Energy capacity we can have
@export var energy_consumption_rate : float = 0.01 # Rate in which we gonna consume energy from our vehicle
@export_range(1, 10) var drain_penalty : int = 6 # Penalty that will be applie to gear_ratio when we run out of energy

@export_group("Wheels")
@export_range(0,3) var wheel_grip : float = 3.0 # Default grip for wheels this will always be the value set in _ready() function
@export_range(0,3) var wet_grip : float = 2.0 # Modifier for penalty on wet surface, "closer to wheel_grip, More drifty it becomse!" Used for handbreak but can also be used in the environment if desired
@export var all_wheels : Array [VehicleWheel3D]

var energy : float # Variable in which we store vehicle energy or fuel
var nav_direction # Variable to store our points that are generated for the path, we need to access this in both, _process and _physical_process
#var path : PackedVector3Array = [] # We define path as a variable for vectors, we might not need it since we are not checking for all the points in path but leave it in case for now if we need it in future


func _ready() -> void:
	
	for x in all_wheels: # Sets the default grip for all the wheels that are in variable
		x.wheel_friction_slip = wheel_grip
		
	if nav is NavigationAgent3D: # Check if we have NavigationAgent3D set and if not, print Warning
		if target_ray: # We check if vehicle have target to reach and if not, print warning. This is here to prevent crash from not having target
			nav.set_target_position(target_ray.global_position) # Generates path to our target when entering the scene on Navigation Mesh. May or may not be needed but keeping it just in case, this will still be updated in _process() function
		else: print_rich("[color=salmon][b]WARNING:[/b] Vehicle is missing target! Vehicle will not move on its own until target has been provided!")
	else: 
		print_rich("[color=salmon][b]WARNING:[/b] Vehicle is missing NavigationAgent3D! Vehicle will not gonna work properly!")
	
	if enable_debug: # Enables NavigationAgent3D Debug path drawing
		nav.debug_enabled = true

	if use_energy: # Checks if we use energy and if so, set it to max_energy
		energy = max_energy


func _process(delta: float) -> void:
	
	if nav is NavigationAgent3D: # Check if we have NavigationAgent3D and if not do nothing, this is here to prevent crashes in case of missing NavigationAgent3D
		if target_ray: # We check if vehicle have target to reach. This is here to prevent crash from not having target to go
			nav.set_target_position(target_ray.global_position) # Generate path to our target position based on Navigation Mesh. !!NOTE!! This need's to be in _process and not _physical_process to prevent issues, since _process starts immiediatly when entering the scene unlike _physical_process
			nav_direction = nav.get_next_path_position() # We get next point on the path that is leading to out main target. NOTE: NavigationAgent3D will go towards another point if it has already previous point on the path
			#path = nav.get_current_navigation_path() # This gets us an array of all the points of the generated path, Don't need it but might keep it just in case


	
func _physics_process(delta: float) -> void:
	
	var target_angle
	var current_angle
	
	var velocity_xz = Vector3(linear_velocity.x, 0, linear_velocity.z) # We take X/Z Velocity of this AI and calculate its length
	var speed_xz = velocity_xz.length() * 2.8
	
	if speed_xz > 0.0 and use_energy: # We check if our calculated velocity is bigger than 0.0 and if soo, drain energy from vehicle
		energy -=energy_consumption_rate
	
	if energy < 0.0 and use_energy: # We check if we have energy and if not then limit it so it does not go into negative values
		energy = 0.0
	
	if nav_direction != null: # Check if we have any points to follow
		
		
		var target_position = nav_direction # Gets position of first point that leads to our target
		var direction = (target_position - self.global_transform.origin).normalized() # We get position of our target minus our transform ortientation then normalize it
		
		var angle = atan2(direction.x, direction.z)  # Limit rotation to Y-Axis only
		current_angle = self.rotation.y  # Get current Y rotation of our vehicle
		
		target_angle = angle - current_angle  # Get the angle difference between our target and vehicle
		target_angle = rad_to_deg(target_angle)  # Convert it to degrees
		target_angle = clamp(target_angle, -steering_sensitivity, steering_sensitivity)  # Clamp vehicle wheels so it does not turn at a weird angle
		steering = deg_to_rad(target_angle)  # Convert back to radians so car can steer on its own without issues
		
		if energy > 0.0 or !use_energy: # Check if our energy is lower than 0.0 and if soo apply penalty to max speed OR Check if we actually don't use energy then apply normal speed
			engine_force = max_speed # Apply our speed to engine force
		else:
			engine_force = max_speed / drain_penalty
			
	# Check if front collider is colliding and check if collided object is in Vehicle Group
	# This is to prevent vehicle slowing down or turning out of nowhere if it reaches another vehicle
	# NOTE: This is not an idiot proof way of fixing it but it will work for now, currently it reverse
	# If it detects obstacle directly in front of it, however, it will not gonna move if there is player in front
	# which means that it will keep player stuck in certain situations, I am planning to fix that soon tho :)
	if front_rc.is_colliding() and not front_rc.get_collider().is_in_group("Vehicle"):
		_reverse_car(delta, target_angle) # Goes to reverse function if conditions are meet
			
	if enable_debug: # We will print some debug settings
		print(nav_direction) # Simple print to get our first point location
		print(target_angle)  # Printing angle to target
		print("Currently facing angle: " + str(current_angle)) # Print our AI Y rotation
		print("Vehicle Speed: " + str(roundi(speed_xz)), "km")
			
			
	# This part makes the car go in reverse if obstacle is in front of it
func _reverse_car(delta: float, target_angle) -> void:
	engine_force = max_rev_speed # Apply negative engine force to make car drive in reverse
	target_angle = target_angle * PI # Get vehicle steering and apply PI to reverse it soo that car will not get stuck
