extends Node3D

@export var cam_parent : Node3D # Reference to the root of this scene
@export var cam_holder : Node3D # Reference to camera anchor that will rotate depending on vehicle angle
@export var camera : Camera3D # Reference to camera itself
@export var cam_positions : Array [Marker3D] # Array of locations where camera should be moved to
@export var cam_angle_limit : int = 45 # Max angle our camera can rotate in X Axis

var current_cam : int = 0 # Reference to camera location we awant to use 


var direction : Vector3 = Vector3.FORWARD # Direction where camera should look
var look_axis : float = 0.0 # Axis for rotation with analogue

var cam_rot_x : float = 0.0 # Target rotation based on input
var cam_current_x : float = 0.0 # Actual applied X rotation (with delay)
var cam_parent_rot_x : float = 0.0 # Parent's X rotation (for smooth following)

const X_SMOOTHNESS : float = 2.0 # Smoothing for X Axis in theory should give small delay
const ROTATION_SMOOTHNESS : float = 1.0 # Smoothness for input-driven rotation (slower = more delay)


# We use this process to change player camera during driving
func _process(delta: float) -> void:
	
	# Input to change camera location depending positions array and current camera reference
	if Input.is_action_just_pressed("Camera Change"):
		if current_cam != 2: # Check if our camera location ID is not equal to 2
			current_cam = current_cam + 1 # Add 1 to camera location ID to change camera
		else: current_cam = 0 # If our camera location ID is 2 then set it to 0 on next button press
		
		# We match our current_camera and with our array entries and place it at its location here 
		camera.reparent(cam_positions[current_cam]) # Reparenting camera to current location
		camera.rotation = Vector3(0,0,0) # We set our rotation vector here, this is to prevent missplacement of camera when switching it
		camera.global_position = cam_positions[current_cam].global_position # Adjust the location of camera to be at our markers location


# The physics of camera starts here
func _physics_process(delta: float) -> void:
	
	var current_velocity = cam_parent.get_parent().get_linear_velocity() # We are calculating linear velocity of our car here
	current_velocity.y = 0 # We dont want to calculate Y velocity since we don't need that

	# Smoothly rotate toward movement direction
	if current_velocity.length_squared() > 1: # Keep at 1 to prevent camera from glithing when holding hand break
		direction = lerp(direction, -current_velocity.normalized(), 2.5 * delta)

	global_transform.basis = get_rot_from_dir(direction)

	# Read input (joystick or any other source for X axis movement)
	# Still in testing, Might be removed later
	look_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)

	# Calculate input-based rotation (cam_rot_x)
	cam_rot_x += look_axis * delta * 1.5  # Adjust multiplier for sensitivity (slower)

	# Restriction for rotating camera in X axis, by default it is +/-45 dgr angle
	cam_rot_x = clamp(cam_rot_x, deg_to_rad(-cam_angle_limit), deg_to_rad(cam_angle_limit))

	# Smooth the actual applied rotation with input (adds the delay effect)
	cam_current_x = lerp(cam_current_x, cam_rot_x, X_SMOOTHNESS * delta)

	# Smoothly follow the parent's X rotation with delay
	var parent = cam_holder.get_parent() as Node3D # We use Node3D in Case if someone wants to use it on different object
	if parent != null: # We don't need that most of the time but just in case if someone wants to use this cam while there is no parent object
		cam_parent_rot_x = lerp(cam_parent_rot_x, parent.global_rotation_degrees.x, ROTATION_SMOOTHNESS * delta) # Smooths the camera rotation for X Axis

	# Combine input-based and parent-based smooth rotations
	cam_current_x = lerp(cam_current_x, cam_parent_rot_x, ROTATION_SMOOTHNESS * delta)

	# Adds smoothing to camera movement in X axis only
	var rot = cam_holder.rotation_degrees
	rot.x = cam_current_x
	# We keep our Y and Z recalculated so it does not get smoothed along
	rot.y = cam_holder.rotation_degrees.y
	rot.z = cam_holder.rotation_degrees.z
	cam_holder.rotation_degrees = rot


	# We now apply our camera to rotate correctly with our car
func get_rot_from_dir(look_direction : Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis, Vector3.UP, -look_direction)
