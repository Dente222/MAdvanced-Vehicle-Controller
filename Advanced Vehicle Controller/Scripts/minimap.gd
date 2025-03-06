extends PanelContainer

@onready var parent_veh = get_parent() # We create direct path to our parent node "In this case it will be our car when minimap is added"
@export var cam_distance : float = 500.0 # How high our minimap is from our vehicle
@export var minimap_cam : Camera3D # Reference to our camera
@export var map_display : SubViewport # Reference to our SubViewport in case we want to modify its values in some way
@export var overdraw_map : bool = false # Check if we want to use Overdraw debug mode as our minimap
@export var rotate_cam : bool = false # Check if we want our minimap to rotate with our vehicle

func _process(delta: float) -> void:
	
	
	# This allows us to switch our Map Rendering between Overdraw and Unshaded
	# Personaly I think that Overdraw looks good as a minimap so I made it an option
	# As an alternative, we also have Unshaded since we don't really need shadows to be visible on our minimap anyways
	if overdraw_map: # If overdraw_map is true 
		map_display.debug_draw = Viewport.DEBUG_DRAW_OVERDRAW # We set our SubViewport to debug Overdraw debug mode to render our map
		map_display.use_taa = overdraw_map # We set our SubViewport TAA to be true otherwise our map will be dark
	else: 
		map_display.debug_draw = Viewport.DEBUG_DRAW_UNSHADED # If we don't want to use Overdraw mode on minimap we simply switch to Unshaded version
		map_display.use_taa = overdraw_map # We are turning TAA off here since it is not requred
	
	# Here is where we set up our camera and its position
	if parent_veh: # We check if we have parent then calculate camera location
		minimap_cam.size = cam_distance # We set our camera size to our distance to give better view on the area
		
		# Here we calculate position of our vehicle and move camera above it
		# Note: By default godot does not allow to move any node that is a child of SubViewport for some reason soo we need to move it by code
		# We take X/Z of our vehicle but we also take Y position and add our cam_distance to keep our camera always at the same distance in Y Axis
		minimap_cam.position = Vector3(parent_veh.position.x, parent_veh.position.y + cam_distance, parent_veh.position.z)
		
	# We check here if we want our minimap to rotate or not
	# If yes then we will rotate it in Y Axis based on our vehicle rotation
	# If not the we set it to default
	# NOTE: We add PI to flip our camera, otherwise it will be rotating in a opposite direction
	# This is because rotation is calculated in Radiants and not Degrees soo in Radiants PI value is equivalent to 180dgr
	if rotate_cam:
		minimap_cam.rotation.y = parent_veh.rotation.y + PI
	else: minimap_cam.rotation.y = 0.0 + PI
		
		
		
		
		
