@icon("res://addons/M.A.V.S/Textures/MTrafficLights.png")
## Proof of concept only! Experimental way of managing Traffic, use MPathManager instead!
extends Area3D

class_name MTrafficSwitch_Depracted

## Array Containing all traffic lanes which cars will be switching between
@export var traffic_lanes : Array[Path3D] 
## Checks if these traffic lights are active or not
@export var deadend : bool = false 
@export var debug : bool = false # Displays some basic Debug functions

var queue_selection : bool = true
var is_switching : bool = false

# This function changes line for vehicle that enters the area at the end of the path
# Its a proof of concept
func _on_area_entered(area: Area3D) -> void:
	var entered_traffic = area.get_parent() # Gets the traffic target that enters the area
	var selected_lane = traffic_lanes.pick_random() # Randomises lanes that are in traffic_lanes array and picks one
	
	if queue_selection and not is_switching: # This is a prevention switch from fiering the script multiple times due to Area3D nature of running script fast
		is_switching = true # Just a switch to prevent it from selecting new lane more than once per car
		queue_selection = false # Same as above, its to prevent Area3D from running script more than once
		if deadend: # Checks if this is an deadend intersection then deactivate the vehicle movement
			entered_traffic.active = false
		await get_tree().create_timer(0.2).timeout # Waits for a while to prevent midjumping between lanes
		#var entered_traffic = area.get_parent() # Takes the parent of our Traffic target which is PathFollow3D
		if debug: print(selected_lane.name) # For debug purpose only
		entered_traffic.reparent(selected_lane) # Reparents our traffic target to another lane on intersection
		entered_traffic.progress = 0.0 # Sets progress to 0.0 of traffic target for the next traffic lane, this is to prevent PathFollow3D from reparenting at the very end of the path
		


# This is to turn off the runtime limit for the traffic lane switch
# It basically rolls back variables to default state, when traffic car exits it
func _on_area_exited(area: Area3D) -> void:
	if !queue_selection and !deadend:
		await get_tree().create_timer(0.2).timeout # Wait before rolling back changes
		queue_selection = true
		is_switching = false
