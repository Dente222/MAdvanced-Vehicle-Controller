@icon("res://addons/M.A.V.S/Textures/MVehicleBody3DAI.png")
extends VehicleBody3D
class_name MVehicleBasicFollowAI

##AI Based on node Location, Its simply and efficient but not accurate enough for anything more

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
@export var race_AI : bool = false # Checks if this is a Race,  in case someone wants to use this one for racing, it gives it a different behaviour
@export var target_ray : Node3D # This is our target that AI will follow
@export_range(1.0, 45.0) var max_steer_angle : float = 40.0 # Max angle our car can turn its wheels
@export var follow_offset : Vector3 = Vector3(0, 0, 0)  # Adds offset for our target in case we want to mix up its target location
@export var veh_indicator : Sprite3D # This is the indicator that is visible on the minimap, its here so it will be togled when car is added instead of having it visible in editor
@export var active_debug : bool = false

@export_group("Traffic Settings")
@export var boost_speed : bool = false # Provides small boost for car to start it faster
@export var max_speed : float = 100.0 # Max power this car will receive
@export var distance_from_target : bool = false # If we want to check distance to our target
@export var take_speed_from_target : bool = false # Takes the speed from our target
@export var despawn_allowed : bool = false # Checks if car can despawn
@export var distance_to_despawn : float = 50.0 # Distance between player and car befor car can despawn 

@export_group("Context steering")
@export var front_rc : RayCast3D # Raycast for context steering WIP!!!
@export var back_rc : RayCast3D # Raycast for context steering WIP!!!
@export var left_rc : RayCast3D # Raycast for context steering WIP!!!
@export var right_rc : RayCast3D # Raycast for context steering WIP!!!

@export_group("Body Settings")
@export var veh_mesh : MeshInstance3D
@export var allow_color_change : bool = false
@export var material_id : int = 1 
@export_color_no_alpha var veh_color : Color = Color(1.0, 1.0, 1.0, 1.0)
@export_range(0, 1) var material_tint : float = 1.0 
@export var random_color : bool = false # Allows to randomise the color of vehicle

@export_category("Vehicle Settings")
@export_subgroup("Energy")
@export var use_energy : bool = false
@export var max_energy : float = 150.0 # Max Energy capacity we can have
@export var energy_consumption_rate : float = 0.01 # Rate in which we gonna consume energy from our vehicle
@export_range(1, 10) var drain_penalty : int = 6 # Penalty that will be applie to gear_ratio when we run out of energy
@export_range(2.0, 10.0) var brakes_limit : float = 10.0

@export_subgroup("Wheels")
@export_range(0,3) var wheel_grip : float = 3.0 # Default grip for wheels this will always be the value set in _ready() function
@export_range(0,3) var wet_grip : float = 2.0 # Modifier for penalty on wet surface, "closer to wheel_grip, More drifty it becomse!" Used for handbreak but can also be used in the environment if desired
@export var all_wheels : Array [VehicleWheel3D]

var energy : float # Variable in which we store vehicle energy or fuel
var spawner : MTrafficSpawner = null # Variable that stores its spawner

func _ready() -> void:
	
	
	if veh_indicator != null: # Check if car have assigned indicator, if not then display message which car don't have one
		veh_indicator.visible = true # We make our vehicle indicator visible only when this car is added into the scene
	else: print_rich("[color=salmon][b]WARNING:[/b] This vehicle don't have assigned map indicator! [color=white]", self.name)
		
	for x in all_wheels: # Sets the default grip for all the wheels that are in variable
		x.wheel_friction_slip = wheel_grip
		
	if target_ray != null and "distance_from_target" in target_ray: # Checks if our target has this parameter, if not Ignore it
		target_ray.distance_from_target = distance_from_target
	
	if use_energy: # Checks if we use energy and if so, set it to max_energy
		energy = max_energy
		
	if allow_color_change and veh_mesh.get_surface_override_material(material_id): # If player is allowed to change colour of this specific vehicle
		if random_color: # Randomises the color for our Traffic car
			var color = Color(randf(), randf(), randf())
			veh_mesh.get_surface_override_material(material_id).albedo_color = color
		else:
			veh_mesh.get_surface_override_material(material_id).albedo_color = veh_color # We get our material that controlls vehicle color and change its albed to our albedo value
		
		veh_mesh.get_surface_override_material(material_id).roughness = material_tint # This one changes roughness of our materiall which makes it matte or shiny metalic
		

func _physics_process(delta: float) -> void:
	
	
	#print("Current Energy: " + str(energy))
	var velocity_xz = Vector3(linear_velocity.x, 0, linear_velocity.z) # We take X/Z Velocity of this AI and calculate its length
	var speed_xz = velocity_xz.length() * 2.8
	
	if speed_xz > 0.0 and use_energy: # We check if our calculated velocity is bigger than 0.0 and if soo, drain energy from vehicle
		energy -= energy_consumption_rate
	
	if energy < 0.0 and use_energy: # We check if we have energy and if not then limit it so it does not go into negative values
		energy = 0.0
	
	if target_ray: # Check if we have target to follow then follow
		
		
		var target = self.position.distance_to(target_ray.position)
		#print(round(target))
		
		#Get offset relative to target's position and rotation
		var target_position = target_ray.global_transform.origin # Grabs global position of our target
		var offset_position = target_position + (target_ray.global_transform.basis * follow_offset)  # Applies offset to our target position

		# Get direction from AI vehicle to offset target position
		var direction = (offset_position - self.global_transform.origin).normalized() # We set direction based on our offset position and our AI vehicle then normalize it

		var angle = atan2(direction.x, direction.z)  # We limit out rotation to Y-Axis only
		var current_angle = self.rotation.y  # Get current Y-Axis rotation of our vehicle

		var target_angle = wrapf(angle - current_angle, -PI, PI)  # Get angle difference between our target and AI vehicle. We use wrapf to fix our car turning opposite when trying to go above 180°
		target_angle = rad_to_deg(target_angle)  # Convert it to degrees for better calculation
		target_angle = clamp(target_angle, -max_steer_angle, max_steer_angle)  # Clamp max angle for steering
		steering = deg_to_rad(target_angle)  # Convert back to radians after clamping cuz it is harder to clamp radiant
		if race_AI: # Checks if our AI is a racing car or traffic
			direction_to_yaw_deg(target_ray, speed_xz, delta) # Run this function if its a racing car to help with speed management and corners
		elif !race_AI: # If its not a Racing AI or still desired to follow something at its own speed without restriction or thinking "Bad for tracks with corners"
			traffic_ai_handler(target_ray, speed_xz, delta)


			#if energy > 0.0 or !use_energy: # Check if our energy is lower than 0.0 and if soo apply penalty to max speed OR Check if we actually don't use energy then apply normal speed
				#engine_force = max_speed
			#else:
				#if target < 5.0:
					#engine_force = max_speed - 50
					#brake = 1.0
				#elif target < 3.0:
					#engine_force = max_speed - 50
					#brake = 10.0
				#elif target < 2.0:
					#engine_force = 0.0
					#brake = 100.0
				#else:
					#engine_force = max_speed
					#brake = 0.0
				#
				#engine_force = max_speed / drain_penalty



func traffic_ai_handler(target: Node3D, speed_xz: float, delta: float) -> void:
	
	
	if despawn_allowed: # Chechks if Car is allowed to despawn
		var closest_player = get_tree().get_nodes_in_group("Player_car")
		if closest_player.size() > 0: # Checks if we have any players on the map
			var targeted_player = closest_player[0] # Gets First player from the list
			var distance_to_player = self.position.distance_to(closest_player[0].global_position)
			
			if distance_to_player > distance_to_despawn: # Despawns car if Player is too far from it
				target_ray.queue_free() # Removes Car target from map
				self.queue_free() # Removes itself from the map
				if spawner != null: # If this car have spawner added then remove one point from it when from the spawner when car despawns
					spawner.spawn_count = spawner.spawn_count - 1 # Remove one counter from our spawner
	
	
	
	# Since it is a traffic setup, we check here if assigned target is active and if soo make it drive
	# otherwise just stop, this is here to make the car stop on traffic lights or when 
	if target_ray.active == true:
		engine_force = max_speed
		brake = 0.0
		
		if target_ray.front_obstacle == true:
			engine_force = 0.0
			brake = brakes_limit # We dont use Lerp here because it takes a small delay for cars to stop which makes them stop a bit too late if many cars queueing on the road
			if speed_xz < abs(1.0):
				freeze = true # This freeze is here to stop the vehicle completely when reaching a stop or traffic lights, prevents that micro movement which makes the car roll slightly with brakes
				await get_tree().create_timer(0.2).timeout
				freeze = false
				
		if target_ray.progress_ratio == 1.0:
			engine_force = 0.0
			brake = 10.0
			if speed_xz < abs(1.0):
				freeze = true # This freeze is here to stop the vehicle completely when reaching a stop or traffic lights, prevents that micro movement which makes the car roll slightly with brakes
				await get_tree().create_timer(0.2).timeout
				freeze = false
	else:
		engine_force = 0.0
		brake = lerp(brake, brakes_limit, delta * 2)
		if speed_xz < abs(1.0):
			freeze = true # This freeze is here to stop the vehicle completely when reaching a stop or traffic lights, prevents that micro movement which makes the car roll slightly with brakes
			await get_tree().create_timer(0.2).timeout
			freeze = false
	

	
	if take_speed_from_target: # Takes speed from our Traffic Target
		
		# Adds some boost to the car to catch up with target
		# Note: In future this might be integrated to the 
		if boost_speed: 
			var distance = self.position.distance_to(target_ray.position) # Gets the distance to target
			#if distance > target_ray.max_distance: # Checks if car is further than 5.0 units from target and if soo, boost its speed to catch up
				#max_speed = target_ray.speed + 10
				#target_ray.actual_speed = target_ray.actual_speed / 12
			if distance < (target_ray.max_distance - 1): # If we are too close to the target then apply brakes gradualy
				brake = lerp(brake, brakes_limit, delta * 2)
				
			else:
				max_speed = target_ray.speed # If we are between 5.0 and 3.0 units, just apply normal target speed
				brake = 0.0 # Release brakes
		else:
			max_speed = target_ray.speed # If we don't use Booster just use targets speed on its own


func direction_to_yaw_deg(target: Node3D, speed_xz: float, delta: float) -> void:
	
	engine_force = max_speed # We apply engine force here because we need to calculate changes later
	


	# Here we calculate the direction from our car to target
	var dir = target_ray.global_position - global_position # gets target position minus global position
	dir.y = 0 # Skip Y drection because or Car will not going to fly, and we only want it at X/Z axis, how high it is does not matter
	if dir.length_squared() == 0: # If our target is exactly at our AI car then return and notify us
		print("Target is at the same position!")

	
	var distance = dir.length() # Takes distance towards the target
	dir = dir.normalized() # We normalize the direction, we do this after getting the distance because otherwise we will get distance between 0-1 values

	# We conver the direction and compare the difference between our car and target
	var yaw_rad = atan2(dir.x, dir.z) # We get the angle towards the target from our vehicle
	var yaw_deg = rad_to_deg(yaw_rad) # Converts direction to degrees
	var veh_angle = self.global_rotation_degrees.y # Takes the direction of our AI car
	
	var angle_diff = yaw_deg - veh_angle # Returns difference in angle between our car and target "In short, it gives the angle in degrees from front of the car to the target location"
	angle_diff = fmod(angle_diff + 180.0, 360.0) - 180.0 # Converts the angle and gives us the exact difference between the direction of our car and target
	
	if distance < 25.0: # If distance to our target is less than 25.0 then cut its speed by 1.5
		engine_force = max_speed / 1.5 # Divide speed if too close to the target
	elif distance < 20.0: # If distance is less than 15.0 then try to reverse the engine
		engine_force = -5.0
		brake = lerp(brake, brakes_limit, delta * 2)
	else: engine_force = max_speed # If distance is above 25.0 do nothing

	if abs(angle_diff) > 8.0: # Check if the difference in angle between our car direction and target is higher than 30dgr both +/-
		# Slows down the car accordingly to the target angle
		if speed_xz > 30.0:
			brake = lerp(brake, brakes_limit, delta * 2) # Smoothly applies force to the brakes
			engine_force = -30.0
		else:
			brake = 0.0
			
	elif abs(angle_diff) < 5.0: 
		brake = 0.0 # If target is less than 30dgr angled from car then do nothing
	
	if active_debug: # Debug options for editor
		print("Yaw angle to target:", yaw_deg, " degrees")
		print("Vehicle Angle: ", veh_angle, " degrees")
		print("Difference in angle is: ", abs(angle_diff), " degrees")
		print("Distance to the target: ", distance)
		print("Brake: ", brake)
		print("Speed: ", roundi(speed_xz) * 1.2)
