@icon("res://Advanced Vehicle Controller/Textures/MVehicleBody3DAI.png")
extends VehicleBody3D
class_name MVehicleBasicFollowAI

## AI Based on node Location, Its simply and efficient but not accurate enough for anything more

#////////////////////////////////////////////////////////////////////////////////////////////////#
# This is where we set up our Vehicle AI based on node global position, our vehicle should
# drive directly to its location and adjust itself accordingly, keep in mind that this is barebone
# and vehicle can get easily stuck on something and not reverse cuz it does not poses this logic
# yet, obviously this will be changed and car will use context steering to avoid obstacles if
# there are any on the way but for now it is basically straight to the point " This include
# driving off the clif if destination is on the other side of it"
# Copyright 2025 Millu30 A.K.A Gidan
#////////////////////////////////////////////////////////////////////////////////////////////////#

@export_category("AI Settings")
@export_group("AI")
@export var distance_from_target : bool = false # If we want to check distance to our target
@export var max_speed : float = 50.0 # Max power this car will receive
@export var target_ray : Node3D # This is our target that AI will follow
@export_range(1.0, 45.0) var max_steer_angle : float = 40.0 # Max angle our car can turn its wheels
@export var follow_offset : Vector3 = Vector3(0, 0, 0)  # Adds offset for our target in case we want to mix up its target location

@export_group("Context steering")
@export var front_rc : RayCast3D # Raycast for context steering WIP!!!
@export var back_rc : RayCast3D # Raycast for context steering WIP!!!
@export var left_rc : RayCast3D # Raycast for context steering WIP!!!
@export var right_rc : RayCast3D # Raycast for context steering WIP!!!

@export_category("Vehicle Settings")
@export_subgroup("Energy")
@export var use_energy : bool = false
@export var max_energy : float = 150.0 # Max Energy capacity we can have
@export var energy_consumption_rate : float = 0.01 # Rate in which we gonna consume energy from our vehicle
@export_range(1, 10) var drain_penalty : int = 6 # Penalty that will be applie to gear_ratio when we run out of energy

@export_subgroup("Wheels")
@export_range(0,3) var wheel_grip : float = 3.0 # Default grip for wheels this will always be the value set in _ready() function
@export_range(0,3) var wet_grip : float = 2.0 # Modifier for penalty on wet surface, "closer to wheel_grip, More drifty it becomse!" Used for handbreak but can also be used in the environment if desired
@export var all_wheels : Array [VehicleWheel3D]

var energy : float # Variable in which we store vehicle energy or fuel

func _ready() -> void:
	
	
	for x in all_wheels: # Sets the default grip for all the wheels that are in variable
		x.wheel_friction_slip = wheel_grip
		
	if "distance_from_target" in target_ray: # Checks if our target has this parameter, if not Ignore it
		target_ray.distance_from_target = distance_from_target
	
	if use_energy: # Checks if we use energy and if so, set it to max_energy
		energy = max_energy

func _physics_process(delta: float) -> void:
	#print("Current Energy: " + str(energy))
	var velocity_xz = Vector3(linear_velocity.x, 0, linear_velocity.z) # We take X/Z Velocity of this AI and calculate its length
	var speed_xz = velocity_xz.length() * 2.8
	
	if speed_xz > 0.0 and use_energy: # We check if our calculated velocity is bigger than 0.0 and if soo, drain energy from vehicle
		energy -= energy_consumption_rate
	
	if energy < 0.0 and use_energy: # We check if we have energy and if not then limit it so it does not go into negative values
		energy = 0.0
	
	if target_ray: # Check if we have target to follow then follow
		
		#Get offset relative to target's position and rotation
		var target_position = target_ray.global_transform.origin # Grabs global position of our target
		var offset_position = target_position + (target_ray.global_transform.basis * follow_offset)  # Applies offset to our target position

		# Get direction from AI vehicle to offset target position
		var direction = (offset_position - self.global_transform.origin).normalized() # We set direction based on our offset position and our AI vehicle then normalize it

		var angle = atan2(direction.x, direction.z)  # We limit out rotation to Y-Axis only
		var current_angle = self.rotation.y  # Get current Y-Axis rotation of our vehicle

		var target_angle = angle - current_angle  # Get angle difference between our target and AI vehicle
		target_angle = rad_to_deg(target_angle)  # Convert it to degrees for better calculation
		target_angle = clamp(target_angle, -max_steer_angle, max_steer_angle)  # Clamp max angle for steering
		steering = deg_to_rad(target_angle)  # Convert back to radians after clamping cuz it is harder to clamp radiant
		
		if energy > 0.0 or !use_energy: # Check if our energy is lower than 0.0 and if soo apply penalty to max speed OR Check if we actually don't use energy then apply normal speed
			engine_force = max_speed # Apply our speed to engine force
		else:
			engine_force = max_speed / drain_penalty
