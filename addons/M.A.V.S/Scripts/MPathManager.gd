@icon("res://addons/M.A.V.S/Textures/MPathManager.png")
extends Path3D


## Custom Path3D that contains other connected paths for Traffic to switch at the end
class_name MPathManager

@export var active : bool = true # Checks if road is active
@export var roads : Array[MPathManager] = [] # Array of all the roads that will be randomly picked by vehicle target itself
var selected_lane : MPathManager = null # Shelf for our picked road


# Picks next road for us
func pick_road() -> void:
	if active: # Checks if this road is Active and if not just dont pick any road
		if roads.size() > 0: # Checks if we have other assigned roads
			selected_lane = roads.pick_random() # Picks random road
		#elif roads.size() == 0 or null: # If no roads or null array, deactivate this road
			#active = false
