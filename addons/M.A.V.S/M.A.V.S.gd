@tool
extends EditorPlugin

# ================================================================================================ #
# This is a slightly modified version of code created by selgesel for his Third person controller
# It was added only as a request by a user to quickly generate default inputs for the game
# This modified version only adds a way to generate Joypad Triggers, Sticks and Buttons 
# The default code can be found here which i strongly recommend :) 
# https://github.com/selgesel/godot4-third-person-controller/commit/2ee520db2751e9d24fd1b511016a1384cd6e139b
# ================================================================================================ #

class Action:
	var name: String
	var deadzone: float
	var events: Array[InputEvent]
	
	func _init(name: String, deadzone: float, events: Array[InputEvent]) -> void:
		self.name = name
		self.deadzone = deadzone
		self.events = events 
		
var actions: Array[Action] = [
	Action.new("Acceleration", 0.2, [
		build_InputEventKey(KEY_UP),
		build_InputEventJoypadAxis(JOY_AXIS_TRIGGER_RIGHT, 1.0) # Trigger axis
	]),
	Action.new("Brake", 0.2, [
		build_InputEventKey(KEY_DOWN),
		build_InputEventJoypadAxis(JOY_AXIS_TRIGGER_LEFT, 1.0)
	]),
	Action.new("Left", 0.2, [
		build_InputEventKey(KEY_LEFT),
		build_InputEventJoypadAxis(JOY_AXIS_LEFT_X, -1.0) # Stick left, -1.0 means left direction
	]),
	Action.new("Right", 0.2, [
		build_InputEventKey(KEY_RIGHT),
		build_InputEventJoypadAxis(JOY_AXIS_LEFT_X, 1.0)  # Stick right, 1.0 means right direction
	]),
	Action.new("Hand Brake", 0.5, [
		build_InputEventKey(KEY_SPACE),
		build_InputEventJoyPadButton(JOY_BUTTON_A)
	]),
	Action.new("Shift Up", 0.5, [
		build_InputEventKey(KEY_Q),
		build_InputEventJoyPadButton(JOY_BUTTON_RIGHT_SHOULDER)
	]),
	Action.new("Shift Down", 0.5, [
		build_InputEventKey(KEY_A),
		build_InputEventJoyPadButton(JOY_BUTTON_LEFT_SHOULDER)
	]),
	Action.new("Lights", 0.5, [
		build_InputEventKey(KEY_F),
		build_InputEventJoyPadButton(JOY_BUTTON_LEFT_STICK)
	]),
	Action.new("Camera Change", 0.5, [
		build_InputEventKey(KEY_C),
		build_InputEventJoyPadButton(JOY_BUTTON_Y)
	]),
	Action.new("Reset", 0.5, [
		build_InputEventKey(KEY_R),
		build_InputEventJoyPadButton(JOY_BUTTON_RIGHT_STICK)
	]),
	Action.new("Nitro", 0.5, [
		build_InputEventKey(KEY_Z),
		build_InputEventJoyPadButton(JOY_BUTTON_X)
	]),
	Action.new("Camera Up", 0.5, [
		build_InputEventKey(KEY_KP_8)
	]),
	Action.new("Camera Down", 0.5, [
		build_InputEventKey(KEY_KP_2)
	]),
	Action.new("Camera Left", 0.5, [
		build_InputEventKey(KEY_KP_6)
	]),
	Action.new("Camera Right", 0.5, [
		build_InputEventKey(KEY_KP_4)
	])
]

func _enter_tree() -> void:
	var subMenu = PopupMenu.new()
	subMenu.add_item("Add actions to M.A.V.S InputMap", 0)
	subMenu.id_pressed.connect(_on_sub_menu_id_pressed)
	add_tool_submenu_item("M.A.V.S InputMap Generator", subMenu)

func _on_sub_menu_id_pressed(id: int):
	match id:
		0:
			add_actions_to_input_map()
	


func add_actions_to_input_map():
	var need_to_save_settings := false
	for action in actions:
		var settings_name = "input/%s" % action.name
		var action_settings = ProjectSettings.get(settings_name)
		var must_set_settings := false
		if action_settings:
			for event in action.events:
				var has_event := false
				for ev in action_settings.events:
					if event is InputEventKey:
						if ev is InputEventKey:
							if event.physical_keycode == ev.physical_keycode:
								has_event = true
								break
					elif event is InputEventMouseButton:
						if ev is InputEventMouseButton:
							if event.button_index == ev.button_index:
								has_event = true
								break
				if !has_event:
					action_settings.events.push_back(event)
					must_set_settings = true
		else:
			must_set_settings = true
			action_settings = {
				deadzone = action.deadzone,
				events = action.events,
			}
		if must_set_settings:
			need_to_save_settings = true
			ProjectSettings.set(settings_name, action_settings)
		else:
			pass
	
	if need_to_save_settings:
		ProjectSettings.save()
		print("Added or updated the actions")
		print("Pleas Reload the project to show the keybinds!")
	else:
		print("All the actions are up-to-date")


func _events_equal(a: InputEvent, b: InputEvent) -> bool:
	if a.get_class() != b.get_class():
		return false

	if a is InputEventKey and b is InputEventKey:
		return a.physical_keycode == b.physical_keycode

	if a is InputEventMouseButton and b is InputEventMouseButton:
		return a.button_index == b.button_index

	if a is InputEventJoypadButton and b is InputEventJoypadButton:
		return a.button_index == b.button_index

	if a is InputEventJoypadMotion and b is InputEventJoypadMotion:
		return a.axis == b.axis

	return false

func build_InputEventKey(
	keycode: int,
) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	
	return event
	
func build_InputEventMouseButton(
	keycode: int
) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = keycode

	return event

# Here starts the additional code writen by Millu30
# This part adds buttons for Joypad
func build_InputEventJoyPadButton(
	keycode: int
) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = -1 # We add device -1 which will be treated as All Devices in InputMap
	event.button_index = keycode
	
	return event

# Here starts the fuction for adding Triggers and Stick controls to InputMap
func build_InputEventJoypadAxis(
	axis: int,
	value: float = 0.0 # We need this to determine which direction we move the stick
	) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.device = -1 # Again -1 means all devices in InputMap
	event.axis = axis
	event.axis_value = value
	
	return event
