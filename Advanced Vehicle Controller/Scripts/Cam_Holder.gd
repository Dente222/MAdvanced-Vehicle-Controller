extends Node3D

var direction = Vector3.FORWARD
var look_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)


func _physics_process(delta: float) -> void:
	var current_velocity = get_parent().get_linear_velocity()
	current_velocity.y = 0
	if current_velocity.length() > 0.1:
		direction = lerp(direction, -current_velocity.normalized(), 2.5 * delta)
	global_transform.basis = get_rot_from_dir(direction)
	
	
func get_rot_from_dir(look_direction : Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis,Vector3.UP,-look_direction)
