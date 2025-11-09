@icon("res://addons/M.A.V.S/Textures/MTraffic.png")
extends PathFollow3D

##Custom PathFollow3D node designed to have all settings ready for traffic system

#////////////////////////////////////////////////////////////////////////////////////////////////#
# Logic for PathFollow3D to follow defined path without any issues, it also adapts to target
# vehicle and calculate distance between itself and vehicle to adjust speed accordingly.
# It can also display distance in Debug Console to have better idea how far our target and
# follower are from each other, besides that there is nothing special about it
# Copyright 2025 Millu30 A.K.A Gidan
#////////////////////////////////////////////////////////////////////////////////////////////////#

class_name MTrafficTarget

@export var active : bool = false # Checks if its actually active and makes it move
@export var sensors : Array[RayCast3D] # List of raycasts for our Target to detect any obstacles and stop if necessary
@export var target_veh : VehicleBody3D # Gets our target to calculate distance and change speed if too far from it
@export_range(20.0, 200.0) var speed : float = 20.0 # Speed in which our PathFollow3D node will move on our path
@export_range(0.0, 100.0) var max_distance : float = 20.0 # Max distance we can set between our Vehicle and PathFollow3D before applying it to the PathFollow3D speed
@export var use_divide : bool = false # Checks if we want to use Division for slowing down our Traffic Target or set it to 0.0
@export var division : int = 12 # This will divide speed, we need this in case our PathFollow3D will be fast enough to outrun our AI Vehicle
@export var distance_from_target : bool = false # Display distance between our target vehicle and PathFollow3D node for debug purpose
var front_obstacle : bool = false # Checks if there are obstacle in front of the Target
var distance : float = 0.0 # Calculates Distance between car and its target


func _process(delta: float) -> void:
	
	# Check if any of our Raycasts actually touches the object then stop the car
	# This stops at any Raycast that touches something, if it stop at first one, it will ignore the rest
	if sensors.any(func(caster: RayCast3D) -> bool: return caster.is_colliding()):
		front_obstacle = true
	else: 
		front_obstacle = false
	
	
	if active and !front_obstacle: # Check if PathFollow3D is active and there is no car in front of it
		if target_veh != null: # Check if we have target, if not just ignore and move
			distance = self.global_position.distance_to(target_veh.global_position) # We calculate distance between PathFollow3D and our vehicle node
			if distance_from_target: # If we want to display distance between PathFollow3D and Vehicle node. NOTE: This is set through the target vehicle and not PathFollow3D itself
				print("Current Distance From Car: ", roundi(distance)) # Display distance in debug console
			if distance > max_distance: # Checks if distance between Vehicle and PathFollow3D is greater than max_distance
				if use_divide:
					self.progress += delta * (speed / division) # If distance between Vehicle and PathFollow3D node is greate than max_distance then divide its speed by 2
				else:
					self.progress + 0.0
			else: self.progress += delta * speed # If distance between nodes is in range of max distance then keep default speed
		else: self.progress += delta * speed # If no target provided, just go along the path

	if self.progress_ratio == 1.0: # Changes lane when reaching End of the path OR deactivates the car completely if no other path provided or deactivated on its own
		var path_node : MPathManager = get_parent() # Gets parent of this node which will be our MPathManager
		if path_node.active == true: # Checks if our road is active, this is related to Traffic Light Manager node
			if path_node.roads.size() > 0: # Checks if we have any roads we can get it assigned to
				active = true # Set the active state to true just in case
				path_node.pick_road() # Trigger function in parent node to pick our road
				var new_path = path_node.selected_lane # Takes our selected road
				self.reparent(new_path) # Reparents our target to new road
				self.progress = 0.0 # Sets progression to 0.0 so it will be at the very beginning of the path
			#elif path_node.roads.size() == 0: # If we don't have any available roads then just stop the car
				#active = false
		else:
			if distance < max_distance: # This will prevent the car from stopping too far if car was is too big
				active = false
			
		
