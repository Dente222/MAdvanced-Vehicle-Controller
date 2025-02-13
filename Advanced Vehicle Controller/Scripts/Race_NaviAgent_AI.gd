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

@export_category("AI Setup")
@export var max_speed : float = 50.0 # Max power this car will receive
@export var front_rc : RayCast3D # Raycast for context steering WIP!!!
@export var back_rc : RayCast3D # Raycast for context steering WIP!!!
@export var left_rc : RayCast3D # Raycast for context steering WIP!!!
@export var right_rc : RayCast3D # Raycast for context steering WIP!!!
@export var nav : NavigationAgent3D # Definition for our navigation agent
@export var target_ray : Node3D # Definition for nodes we want our AI to generate path to
@export var steering_sensitivity: float = 40.0 # Max angle our car cant turn its wheels
var nav_direction # Variable to store our points that are generated for the path, we need to access this in both, _process and _physical_process
#var path : PackedVector3Array = [] # We define path as a variable for vectors, we might not need it since we are not checking for all the points in path but leave it in case for now if we need it in future

func _ready() -> void:
	
	if nav: # Check if we have NavigationAgent3D set and if not, print Warning
		nav.set_target_position(target_ray.global_position) # Generates path to our target when entering the scene on Navigation Mesh. May or may not be needed but keeping it just in case, this will still be updated in _process() function
	else: 
		print("WARNING: Vehicle missing NavigationAgent3D, vehicle will not gonna work properly!")



func _process(delta: float) -> void:
	
	if nav: # Check if we have NavigationAgent3D and if not do nothing, this is here to prevent crashes in case of missing NavigationAgent3D
		nav.set_target_position(target_ray.global_position) # Generate path to our target position based on Navigation Mesh. !!NOTE!! This need's to be in _process and not _physical_process to prevent issues, since _process starts immiediatly when entering the scene unlike _physical_process
		nav_direction = nav.get_next_path_position() # We get next point on the path that is leading to out main target. NOTE: NavigationAgent3D will go towards another point if it has already previous point on the path
		#path = nav.get_current_navigation_path() # This gets us an array of all the points of the generated path, Don't need it but might keep it just in case

	
func _physics_process(delta: float) -> void:
	
	if nav_direction != null: # Check if we have any points to follow
		print(nav_direction) # Simple print to get our first point location

		var target_position = nav_direction # Gets position of first point that leads to our target
		var direction = (target_position - self.global_transform.origin).normalized() # We get position of our target minus our transform ortientation then normalize it

		var angle = atan2(direction.x, direction.z)  # Limit rotation to Y-Axis only
		var current_angle = self.rotation.y  # Get current Y rotation of our vehicle

		var target_angle = angle - current_angle  # Get the angle difference between our target and vehicle
		target_angle = rad_to_deg(target_angle)  # Convert it to degrees
		target_angle = clamp(target_angle, -steering_sensitivity, steering_sensitivity)  # Clamp vehicle wheels so it does not turn at a weird angle

		steering = deg_to_rad(target_angle)  # Convert back to radians so car can steer on its own without issues
		print(target_angle)  # Printing angle to target
		print("Currently facing angle: " + str(current_angle)) # Print our AI Y rotation
		
		var speed = max_speed # Keep our speed in case we want to modify it later
		engine_force = speed # Apply our speed to engine force
