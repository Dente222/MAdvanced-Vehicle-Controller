extends PathFollow3D

##////////////////////////////////////////////////////////////////////////////////////////////////##
## Logic for PathFollow3D to follow defined path without any issues, it also adapts to target
## vehicle and calculate distance between itself and vehicle to adjust speed accordingly.
## It can also display distance in Debug Console to have better idea how far our target and
## follower are from each other, besides that there is nothing special about it
## Copyright 2025 Millu30 A.K.A Gidan
##////////////////////////////////////////////////////////////////////////////////////////////////##


@export var active : bool = false
@export var target_veh : VehicleBody3D # Gets our target to calculate distance and change speed if too far from it
@export_range(20.0, 200.0) var speed : float # Speed in which our PathFollow3D node will move on our path
@export_range(0.0, 100.0) var max_distance : float = 20.0 # Max distance we can set between our Vehicle and PathFollow3D before applying it to the PathFollow3D speed
@export var division : int = 4 # This will divide speed, we need this in case our PathFollow3D will be fast enough to outrun our AI Vehicle
var distance_from_target : bool = false # Display distance between our target vehicle and PathFollow3D node for debug purpose

func _process(delta: float) -> void:
	
	#if active: # Check if PathFollow3D is active and if it is then move around defined path, otherwise do nothing
	var distance = self.position.distance_to(target_veh.position) # We calculate distance between PathFollow3D and our vehicle node
	if distance > max_distance: # Checks if distance between Vehicle and PathFollow3D is greater than max_distance
		self.progress += delta * (speed / division) # If distance between Vehicle and PathFollow3D node is greate than max_distance then divide its speed by 2
	else: self.progress += delta * speed # If distance between nodes is in range of max distance then keep default speed

	if distance_from_target: # If we want to display distance between PathFollow3D and Vehicle node. NOTE: This is set through the target vehicle and not PathFollow3D itself
		print("Current Distance From Car: " + str(distance)) # Display distance in debug console
