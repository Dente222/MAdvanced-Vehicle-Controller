extends Node3D

@export var cam_holder : Node3D

var direction = Vector3.FORWARD
var look_axis := 0.0

var cam_rot_x := 0.0       # Target rotation based on input
var cam_current_x := 0.0   # Actual applied X rotation (with delay)
var cam_parent_rot_x := 0.0  # Parent's X rotation (for smooth following)

const X_SMOOTHNESS := 2.0  # Smoothness for the delay on X rotation (lower is slower, higher is snappier)
const ROTATION_SMOOTHNESS := 1.0  # Smoothness for input-driven rotation (slower = more delay)

func _physics_process(delta: float) -> void:
	var current_velocity = get_parent().get_linear_velocity()
	current_velocity.y = 0

	# Smoothly rotate toward movement direction
	if current_velocity.length_squared() > 1:
		direction = lerp(direction, -current_velocity.normalized(), 2.5 * delta)

	global_transform.basis = get_rot_from_dir(direction)

	# Read input (joystick or any other source for X axis movement)
	look_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)

	# Calculate input-based rotation (cam_rot_x)
	cam_rot_x += look_axis * delta * 1.5  # Adjust multiplier for sensitivity (slower)

	# Clamp the X rotation to avoid flipping
	cam_rot_x = clamp(cam_rot_x, deg_to_rad(-60), deg_to_rad(60))

	# Smooth the actual applied rotation with input (adds the delay effect)
	cam_current_x = lerp(cam_current_x, cam_rot_x, X_SMOOTHNESS * delta)

	# Smoothly follow the parent's X rotation with delay
	var parent = cam_holder.get_parent() as Node3D
	if parent != null:
		cam_parent_rot_x = lerp(cam_parent_rot_x, parent.global_rotation_degrees.x, ROTATION_SMOOTHNESS * delta)

	# Combine input-based and parent-based smooth rotations
	cam_current_x = lerp(cam_current_x, cam_parent_rot_x, ROTATION_SMOOTHNESS * delta)

	# Apply the smoothed X rotation, but preserve the Y and Z rotations
	var rot = cam_holder.rotation_degrees
	rot.x = cam_current_x
	# Ensure Y and Z remain unaffected by the smoothing
	rot.y = cam_holder.rotation_degrees.y
	rot.z = cam_holder.rotation_degrees.z
	cam_holder.rotation_degrees = rot


func get_rot_from_dir(look_direction : Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis, Vector3.UP, -look_direction)
