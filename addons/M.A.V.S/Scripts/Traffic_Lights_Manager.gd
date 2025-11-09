@icon("res://addons/M.A.V.S/Textures/MTrafficLightsManager.png")
extends Node

## Node that manages and switches traffic everywhere
class_name MTrafficLightsManager

@export_subgroup("Settings and paths")
@export_range(1, 100) var time_intervals : int = 5 # Sets the delay between switching lights
@export var traffic_lights_A : Array[MPathManager] # Array of paths that will be switched between two different sets
@export var traffic_lights_B : Array[MPathManager]

var lines_ID : int = 0 # Switch between two of our arrays

func _ready() -> void:
	if self.get_child_count() > 0: # Checks if our node has a timer
		self.get_child(0).start(time_intervals) # Starts timer based on our interval
	else:
		print("Error! No Timer has been provided!") # Error message in case one forgets to add timer node

func _on_timer_timeout() -> void: # Runs the script every time tumers finishes
	if traffic_lights_A.size() > 0 and traffic_lights_B.size() > 0: # Checks if our arrays are not empty
		match lines_ID : # Matches the ID so it can deactivate every line in specified array
			0:
				traffic_lights_B.map(func(road): road.active = false) # Deactivate everything in Arra B
				traffic_lights_A.map(func(road): road.active = true) # Activate Everything in Array A
				lines_ID = 1 # Change the ID
			1:
				traffic_lights_B.map(func(road): road.active = true)
				traffic_lights_A.map(func(road): road.active = false)
				lines_ID = 0
