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

@export_category("AI Setup")
@export var distance_from_target : bool = false # If we want to check distance to our target
@export var max_speed : float = 50.0 # Max power this car will receive
@export var front_rc : RayCast3D # Raycast for context steering WIP!!!
@export var back_rc : RayCast3D # Raycast for context steering WIP!!!
@export var left_rc : RayCast3D # Raycast for context steering WIP!!!
@export var right_rc : RayCast3D # Raycast for context steering WIP!!!
@export var target_ray : Node3D # This is our target that AI will follow
@export var max_steer_angle : float = 40.0 # Max angle our car can turn its wheels
@export var follow_offset: Vector3 = Vector3(0, 0, 0)  # Adds offset for our target in case we want to mix up its target location

func _ready() -> void:
	
	if "distance_from_target" in target_ray: # Checks if our target has this parameter, if not Ignore it
		target_ray.distance_from_target = distance_from_target

func _physics_process(delta: float) -> void:
	
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
		
		var speed = max_speed # Keep our speed in case we want to modify it later
		engine_force = speed # Apply our speed to engine force
