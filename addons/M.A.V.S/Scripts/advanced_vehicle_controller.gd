@icon("res://addons/M.A.V.S/Textures/MVehicleBody3D.png")
extends VehicleBody3D
##Vehicle Body with advanced settings and lots of customisation!

#////////////////////////////////////////////////////////////////////////////////////////////////#
# MAdvanced vehicle system for Godot 4+, created by Millu30
# This vehicle system was made with an intention to provide more advance features such as
# transmission, lights, tyre smoke, grip controll and more features while keeping it basic and
# easy to modify according to own needs/preferences, its more simply and easy to understand
# version of Vita Vehicles that utilize the VehicleBody3D and VehicleWheel3D Node.
# I tried to provide enough informations and explain what everything does for better understanding
#================================================================================================#
# Special thanks to OSH QRD for providing some tweaks to the car logic :)
#================================================================================================#
# Disclaimer! This might not be the most optimal way of solving some issues but it is enough
# to build around it. If there is anything that can be optimised or changed feel free
# to modify it as you like! :)
#================================================================================================#
# MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#================================================================================================#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#================================================================================================#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#================================================================================================#
# Setting up keybinds and controlls for the cars is very simple, one can use a build in Input Map
# generator or simply add them manually, each car can have different Input Map Actions but overall
# script provides you the default actions for your all desires!
# Here is what default action keys should do what:
# Arrow Up or RT = Acceleration : Key Accelerate
# Arrow Down or LT = Brak / Reverse : Key Brake
# Arrow left or LStick to the left = Turn Left : Key Turn Left
# Arrow right or LStick to the right = Turn Right : Key Turn Right
# Q Or RB = Change Gear up : Key Shift Up
# A Or LB = Change Gear down : Key Shift Down
# Space or A = Handbrake : Key Handbrake
# F or Press LStick = Lights : Key Lights
# C or Y = Change camera : Key Camera
# R or Press RStick = Reset vehicle : Key Reset
# Z or X = Nitro : Key Nitro
#================================================================================================#
# Extra keys that are not available here, used to rotate camer
# This keys are addition and should not be modified in game if not necessary
# Numpad 4 = Rotate camera left
# Numpad 6 = Rotate camera right
# Numpad 8 = Tilt Camera Up
# Numpad 2 = Tilt Camera Down
# Tilting RStick on Joypad will rotate camera by default, numpad keys are alternative for keyboard
#================================================================================================#
# Copyright 2025 Millu30 A.K.A Gidan
#================================================================================================#
#////////////////////////////////////////////////////////////////////////////////////////////////#

class_name MVehicle3D # Class name for easy access in other scripts and in create node window

@export_group("Vehicle settings")
@export var player_veh_ID : int = 0 # Assigns intager ID to the car, potential use for multiplayer
@export var veh_name : String # Sets vehicle name. Treat it as ID for custom body mods and decals. It is not necessary to use but makes it easier to restrict exclusive mods or decals for specific vehicle so they don't look missplaced
@export var is_current_veh : bool = false # Sets vehicle to be the current vehicle, sets camera and allow player to controll vehicle that has this checked on, works similar to the car swith in Need For Speed Mostwanted from 2012
@export var veh_mesh : MeshInstance3D # We take path to our vehicle mesh for future reference
@export var front_light : Node3D # Reference to front car lights [Note: We dont reference light nodes itself here, only their parrent node since we dont need that, obviously we can if we need too but not in this case]
@export var rare_lights : Node3D # Reference to rare car lights [Note: We dont reference light nodes itself here, only their parrent node since we dont need that, obviously we can if we need too but not in this case]
@export var decal_markers : Array = [Decal] # Optional if player wants to add decals to vehicle. Keep it in that order to prevent mistakes [0 = Hood, 1 = Left side, 2 = Right side, 3 = Trunk, 4 = Roof]. NOTE: Keep decals empty or simply ignore this and reference to them only when wanting to remove or replace decals 
@export var hood_cam : Marker3D # Marker where hood camera will be placed
@export var remote_transformer : RemoteTransform3D # Reference to RemoteTransformer3D which is used make camera follow, its made this way due to rework of camer system which lets player to rotate camera freely along with keeping its old functionality. Its better than forcing camera position via code every tick
@export var debug_hud : bool = false # Displays debug hud for the vehicle such as Acceleration, speed and gears ratio


@export_subgroup("Steering")
enum steering_type {DEFAULT, OSH_QRD_STEERING} # Types of steering system that can be used by the player
@export var steering_model : steering_type # Check if player want to use alternative steering
@export_range(2.0, 10.0) var default_turn_delay : float = 5.0 # Determines how fast wheels will turn and straighten up
@export_range(0.3, 0.8) var turn_angle : float = 0.4 # Angle in which cars wheel can turn
@export var steering_acceleration : float = 2.0 # How fast wheels will turn when player turns them
@export var steering_return_speed : float = 3.0 # How fast wheels will positione themselves back

@export_subgroup("Sounds settings")
@export var engine_pitch_modifier : float = 50 # Sets the modifier to adjust engine pitch sound accordingly
@export var engine_sound : AudioStreamPlayer3D # Reference to engine sound
@export var tyre_sound : AudioStreamPlayer3D # Reference to our tyre audio stream

@export_subgroup("Particles settings")
@export var smoke_particles : Array [GPUParticles3D] # Array of our particle nodes for easy access
@export var skidmarks_particle : Array [GPUParticles3D]

@export_subgroup("Colour settings")
@export var allow_color_change : bool = true # We check if Player is allowed to change vehicle colour or not, you can restrict some vehicle from their colour to be changed if necessary
@export var material_id : int = 1 # This determines which overrided material we wanna change colour of, my vehicles have 2 materials "0: for windows and details, and 1: for actuall body colour of the vehicle" this way we determine which material we wanna change and prevent from changing wrong material 
@export_color_no_alpha var veh_color : Color = Color(1.0, 1.0, 1.0, 1.0) # We set our color for vehicle here "Default is White" We apply this then directly add it to our veh_mesh and override material albedo with our albedo colour NOTE: Car should not use any color texture, if you want to use premade texture on it then dissable Allow Colour Change!
@export_range(0, 1) var material_tint : float = 1.0 # This determines how rough is our vehicle body 0 means its shiny and metalic while 1 is matte paint

@export_group("Keybinds") # Set of default Action Mapping names for the vehicle system, Change it to whatever you like
@export var key_accelerate : String = "Acceleration"
@export var key_brake : String = "Brake"
@export var key_turn_left : String = "Left"
@export var key_turn_right : String = "Right"
@export var key_shift_up : String = "Shift Up"
@export var key_shift_down : String = "Shift Down"
@export var key_handbrake : String = "Hand Brake"
@export var key_lights : String = "Lights"
@export var key_camera : String = "Camera Change"
@export var key_reset : String = "Reset"
@export var key_nitro : String = "Nitro"

@export_subgroup("Custom Gears") # Additional Action mappings specific to each gear if one wants to add shifter to the game
@export var key_gear_1 : String
@export var key_gear_2 : String
@export var key_gear_3 : String
@export var key_gear_4 : String
@export var key_gear_5 : String
@export var key_gear_reverse : String


@export_group("Bodymod settings")
@export var mod_list : Script # A file that will contain the array of all available mods for the specific car, each car should have its own library file, but that does not mean one canot make a modular file containing all mods for all cars
@export var hood_location : Marker3D # Location where our Hood mods will be placed on the car
@export var front_bumper_location : Marker3D # Location where our Front Bumper will be placed
@export var rare_bumper_location : Marker3D # Location where our Rare Bumper will be placed
@export var spoiler_location : Marker3D # Location where spoiler will be added to the car
@export var no_default_spoiler : bool = false # This checks if car has a stock spoiler and if not then first part in spoiler array will always be skipped

@export_subgroup("Bodymod ID's")
# Here are the ID's for all the mods that are in our mod list file, 0 means stock parts for the car
@export var hood_mod : int = 0
@export var front_bumper_mod : int = 0
@export var rare_bumper_mod : int = 0
@export var spoiler_mod : int = 0

@export_subgroup("Rims Settings")
@export var rim_list : Script # File that contains our rims, just like mod_list does
@export var separate_rim_colors : bool = false # This allows to color front and back rims independly!
@export var default_rims : String # Scene containing Default rims for the car
@export var use_default_rims_front : bool = true # Uses the default rims by default at the beginning for the front
@export var use_default_rims_back : bool = true # Uses the default rims by default at the beginning for the back
@export_color_no_alpha var both_rim_color : Color = Color(1.0, 1.0, 1.0, 1.0) # Applies color for front and back rims
## Material tint is still WIP, this will be added in next update :)
@export_range(0, 1) var both_rim_material_tint : float = 1.0 # Applies material for front and back rims
@export_subgroup("Rims Settings/Front Rims")
@export var front_rim_id : int = 0 # Picks Rim ID for front wheels
@export_color_no_alpha var front_rim_color : Color = Color(1.0, 1.0, 1.0, 1.0) # Sets Rim color for front rims
## Material tint is still WIP, this will be added in next update :)
@export_range(0, 1) var front_rim_material_tint : float = 1.0 # Sets Rim material for front rims
@export_subgroup("Rims Settings/Back Rims")
@export var back_rim_id : int = 0 # Picks Rim ID for back wheels
@export_color_no_alpha var back_rim_color : Color = Color(1.0, 1.0, 1.0, 1.0) # Sets Rim color for back rims
## Material tint is still WIP, this will be added in next update :)
@export_range(0, 1) var back_rim_material_tint : float = 1.0 # Sets Rim material for back rims


@export_group("Transmission settings")
enum transmission {automatic, manual} # Enum for transmission. Allows to change between Manual and Automatic gearbox
@export var gearbox_transmission : transmission # This allows to change vehicle transmision, use it along settings menu to switch.
@export var shifter : bool = false # Allows to switch function for manual shifter instead of buttons if desired to use steering wheel instead
@export var gear_ratio : Array = [0.0, 7.0, 6.0, 5.8, 5.5, 4.0] # Adjustable Gear ratio for cars, works along with differential Note: First value which is 0.0 is for neutral gear only!
@export var differential : Array = [0.0, 33.0, 25.0, 24.0, 22.0, 20.0] # Differential so that vehicle RPM does not get limited by RPM limit, Adjust Carefully along with gear_ratio
@export_range(0, 2) var reverse_ratio : float = 1.5 # Reverse Ratio defines how fast and how many RPM will car get when driving backwards
@export var ratio_limiter : Array = [400, 600, 720, 1000] # Tells us at what point our RPM will switch to the next gear, modify along with Gear Ratio and Differential to prevent inconsystency
@export var manual_ratio_limiter : Array = [150 , 400, 550, 720] # Tells us at what RPM our gear should start limiting our speed, this is separate to Automatic since automatic does not prvent gears from driving faster!
@export_range(0, 2000) var max_rpm : float = 220 # Vehicle MAX RPM that will be modified by gear ratio, commonly used in transmission to limit its engine force based on current gear, lower value might cause gearbox to ignore engine force and allow for infinite acceleration 
@export var rpm_wheel : VehicleWheel3D # A wheel that you wish to calculate RPM from, its recomended to use wheel that has traction ON!

@export_subgroup("NOS settings")
enum nitro_trigger_type {hold, triggered} # Enum defining 2 ways to trigger NOS. Hold: Will use NOS when button is held. Trigger: Will start depleating NOS untill it runs out "Similar way like is in Need For Speed ProStreet"
@export var nos_system : nitro_trigger_type # This will pick what NOS trigger is used
enum nos_level {Empty, Tier1, Tier2, Tier3} # Tiers of NOS that we have available.
@export var nos : nos_level # Selects the tier of the NOSS
@export var nos_power : Array = [0.0, 25.0, 50.0, 75.0] # NOS power rate that we will apply to our engine power based on NOS tier
@export var nos_consumption_rate : Array = [0.0, 0.28, 0.82, 1.0] # The rates in which NOS is consumed when in use
@export var nos_tank : Array = [0.0, 100.0, 200.0, 300.0] # Capacity for NOS tanks based on Tiers
@export var nos_drift_bonus : float = 0.2 # Determines how much NOS is added back to our tank, this is multiplied by the tier of our NOS for example 0.2 * Tier3 will multiply it by 3

@export_group("Vehicle Energy settings")
@export var use_energy : bool = true # Checks if we should use energy or not
@export var max_energy : float = 150.0 # Max Energy capacity we can have
@export var energy_consumption_rate : float = 0.01 # Rate in which we gonna consume energy from our vehicle
@export_range(1, 10) var drain_penalty : int = 6 # Penalty that will be applie to gear_ratio when we run out of energy

@export_group("Wheels settings")
@export_range(0,3) var wheel_grip : float = 3.0 # Default grip for wheels this will always be the value set in _ready() function
@export_range(0,3) var wet_grip : float = 2.0 # Modifier for penalty on wet surface, "closer to wheel_grip, More drifty it becomse!" Used for handbreak but can also be used in the environment if desired
@export_range(0.2, 1.0) var burnout_slip : float = 0.5 # Determines the grip for burnout
@export var wheels : Array [VehicleWheel3D] # Array of all wheels that player wants to apply wet_grip modifier
@export var all_wheels : Array [VehicleWheel3D] # Array of all car wheels in case we want to apply different grip based on map setting to all wheels

@export_subgroup("Wheel Damage")
@export var can_puncture : bool = false # Allows for tire puncture
@export var tire_points : Array [ShapeCast3D] # List of Shapecasts that will check for object that will make the tires puncture


var steering_input : float = 0.0 # Steerting input positon
var nos_in_tank : float = 0.0 # Quantity of NOS we have in our tank
var nos_boost : float = 0.0 # Boost to Engine power that NOS adds, 0.0 means NOS is not active
var nos_lock : bool = false # Triggers NOS and blocks it from turnig it off "Used for Trigger NOS settings"
var punctured_tires : Array = [false, false, false, false] # Array to check what tire is punctured. It works as a tag to determine which tire is punctured, it should apply with the same order as the wheels. Note: This is used to prevent handbrake from glitching and changing tires friction back to default even when tires were flat
var wheel_def_radius : float # This is the radius of our wheels that we set when we make them, we need this to imitate the visual of a flat tire, for some reason we can't decrease its value directly and when we try that it sets the value instead
var acceleration : float # Controlls value of acceleration, range from -1 to 1. Note: this support controllers too!
var veh_speed : float # Displays Vehicle speed, not very accurate but can be adjusted below
const speed_modifier : float = 2.8 # Modifies actuall speed to be more accurate on speed o metter
var gear : int = 0 # Displays current gear based on gear_ratio
var can_reset : bool = true # Switch to allow player to reset vehicle and set cooldown to prevent spamming it
var energy : float # Variable in which we store vehicle energy or fuel and exports it to progress bar in UI scene
var camera_scene : PackedScene = load("res://addons/M.A.V.S/Scenes/cam_holder.tscn") # We Instantiate our vehicle main camera and add it to our vehicle as a child node
var minimap : PackedScene = load("res://addons/M.A.V.S/Scenes/MinimapCamera.tscn") # We Instantiate our Minimap Scene and add it to our vehicle as a child node, this will create camera above our car and add necessary markers to id also adds smal display for our minimap
var minimap_node : CanvasLayer # This lets us find the node that contains minimap since it is containing also our UI instead of having UI as a global scene

# Everything that needs to be set when our car is initiated
func _ready() -> void:
	
	
	if allow_color_change and veh_mesh.get_surface_override_material(material_id): # If player is allowed to change colour of this specific vehicle
		veh_mesh.get_surface_override_material(material_id).albedo_color = veh_color # We get our material that controlls vehicle color and change its albed to our albedo value
		veh_mesh.get_surface_override_material(material_id).roughness = material_tint # This one changes roughness of our materiall which makes it matte or shiny metalic
		
	if mod_list != null: # Checks if car has a file with mods and if not just do nothing
		add_visuals() # Run function for adding visual parts for the car
	
	modify_rims()
	
	if is_current_veh: # Sets viewport to use provided camera. Read comment on is_current_veh variable to learn more
		# We preload our scene containing camera and instantiate it
		# then we add it as a child node to our car but only if this is the car we want to drive
		# otherwise camera will not be attached
		energy = max_energy # We set vehicle energy to its max limit soo it is full
		nos_in_tank = nos_tank[nos] # We set our NOS tank to its limit
		if is_multiplayer_authority(): # Adds minimap and camera only on a clienside for each player, to prevent from issues in multiplayer
			self.add_child(minimap.instantiate()) # Adds Minimap to the vehicle we controll
			minimap_node = get_node_or_null("Players_Minimap") # We reference our Minimap node here that contains the gui for the cars
			self.add_child(camera_scene.instantiate()) # Adds preloaded and instantiated camera scene to our car
		minimap_node.fuel_bar.max_value = max_energy
		minimap_node.nos_bar.max_value = nos_in_tank
		minimap_node.debug_hud.visible = debug_hud # This will make our Debug hud visible or not
		remote_transformer.remote_path = remote_transformer.get_parent().get_node("Camera_Anchor").get_path() # Since our camera is added via code and not attached to vehicle by default, we reference its first node to RemoteTransform3D node which allow us to rotate it while driving
		engine_sound.playing = true
		wheel_def_radius = rpm_wheel.wheel_radius # This one sets the default radius of our wheels based on the radius of our RPM wheel, we need this to decrease the radius when wheel is punctured since we cant simply decrease it directly cuz that way it will replace the value of the wheel radius
		self.add_to_group("Player_car") # Adds player controller car ONLY! to the Player_car groupe
		
		for x in all_wheels: # Sets the default grip for all the wheels that are in variable
				x.wheel_friction_slip = wheel_grip



# Everything that is triggered on Physical CPU Ticks
func _physics_process(delta: float) -> void:
	
	var speed_xz # Our Speed variable reference
	var rpm # RPM reference
	var rpm_calclated # Calculated RPM reference
	acceleration = 0.0 # We will be setting acceleration to 0.0 on every physical tick just in case
	
	# We check if our car can have punctured tires then we apply changes to the wheels
	if can_puncture:
		puncture_wheels()
	
	skiding_effects()
	
	
	# Applies basic controlls and displays informations of currently driveable vehicle
	# if vehicle is not selected as main one then it will not provide any info for player
	# also player will not be able to controll it
	if is_current_veh:
		var velocity_xz = Vector3(linear_velocity.x, 0, linear_velocity.z) # Gets linear velocity of our vehicle in X/Z axis to calculate speed NOTE: We are ignoring Y axis here soo no sound neither speed will be calculated when car will be falling off in Y axis only
		speed_xz = velocity_xz.length() # Calculates linear velocity of our vehicle to be used in Speed o meter and engine sound
		
		# Check which steering version player wants to use
		match steering_model:
			steering_type.DEFAULT:	# Default steering model
				steering = lerp(steering, Input.get_axis(key_turn_right, key_turn_left) * turn_angle, default_turn_delay * delta) # Allows our vehicle to turn. Note: This already supports gamepad!
			steering_type.OSH_QRD_STEERING:	# Uses the way of steering provided by OSH QRD
				var target_input = Input.get_axis(key_turn_right, key_turn_left) # Gets the input of our steering
				if target_input != 0.0: # Checks if our wheels are actually turned or not
					steering_input = move_toward(steering_input, target_input, steering_acceleration * delta) # Sets the steering with specifc speed for turning
				else:
					steering_input = move_toward(steering_input, 0.0, steering_return_speed * delta) # Sets the steering back to 0 with specific speed
				steering = steering_input * turn_angle # Adapts the wheels with turn angle
		
		acceleration = Input.get_axis(key_brake, key_accelerate) # Allows our car to move forward and reverse. Controller supported!
		veh_speed = speed_xz * speed_modifier # Gets vehicle velocity and multiplies it to get semi accurate velocity display on speed o meter, adjustable
		rpm = rpm_wheel.get_rpm() # Gets RPM from our selected wheel
		rpm_calclated = clamp(rpm, -max_rpm * gear_ratio[gear], max_rpm * gear_ratio[gear]) # Gets our RPM and calculate it to have max negative RPM and positive RPM to limit our geabox and overall power
		
		
		if !use_energy: # We check if our vehicle uses energy and if not then Hide the bar
			minimap_node.fuel_bar.visible = false
		
		if nos == 0: # We check if any Nos is installed in our car and if so then show Nos bar
			minimap_node.nos_bar.visible = false
		else: minimap_node.nos_bar.visible = true
		
		# If we have more energy and our acceleration is not 0.0 then drain energy
		# We check for acceleration to prevent car from loosing energy when in mid air
		# We also check if we do use energy "Used for different gamemodes when needed"
		if energy > 0.0 and use_energy:
			if acceleration != 0.0:
				energy -= energy_consumption_rate # We gonna decrease energy by its consumption rate every physical frame we are making our car drive
		
		
		# Some On Screen debug stats to track whats going on with our car
		minimap_node.acceleration.text = "Acceleration: " + str(acceleration)
		if gear == -1: # This one checks if our gear is -1 "Reverse" and if soo then change icon to R, otherwise display gears properly
			minimap_node.gear_shaft.text = "Gear: R"
		elif gear == 0: 
			minimap_node.gear_shaft.text = "Gear: N"
		else: minimap_node.gear_shaft.text = "Gear: " + str(gear)
		minimap_node.absolute_rpm.text = "Absolute RPM: " + str(roundi(veh_speed)) + " KMPH"
		minimap_node.max_rpm.text = "Current Engine Force: " + str(engine_force) + " Multiplied by: " + str(gear_ratio[gear])
		minimap_node.rpm.text = "Current RPM: " + str(rpm_calclated)
		minimap_node.fuel_bar.value = energy
		minimap_node.nos_bar.value = nos_in_tank
		
		engine_sound.pitch_scale = speed_xz/engine_pitch_modifier + 0.1 # Sets the pitch of our vehicle engine sound based on its velocity
		
		#//////////////////////////////////////////////////////////////////////////////////////////#
		# Applies break instead of reverse gear when Acceleration is negative and RPM's are high.
		# Also prevents cars from being sling shooted when suddenly pressing reverse button.
		# Keep it at -0.11 to prevent instant breaking when leaving throrile
		# Note: This needs to check for both Acceleration and RPM, otherwise it might cause
		# some issues with gears being applied incorrectly
		if acceleration <= -0.11 and rpm_calclated >= 0.00:
			brake = 2.0
		else: brake = 0.0
		
		
		#//////////////////////////////////////////////////////////////////////////////////////////#
		# Checks if our Acceleration is at -0.11 "Just like with brakes" then turns rare lights
		# ON and if Acceleration is above this value then turns it OFF
		if acceleration <= -0.11:
			rare_lights.show()
		else: rare_lights.hide()
		
		#//////////////////////////////////////////////////////////////////////////////////////////#
		# Checks If we have NOS lock, this is based on the way we want our NOS to be triggered
		# There are 2 ways of triggering NOS. 1) Traditionall while holding button
		# 2) Tap NOS button to use it until it runs out, NFS ProStreet NOS system
		if !nos_lock:
			nos_boost = 0.0 # We constantly reset our NOS Boost rate to prevent constant boost
			if Input.is_action_pressed(key_nitro): # This checks if we are holding NOS Button
				match nos_system: # We check which trigger type for the NOS our car uses
					0: # Hold Button to use NOS
						if nos_in_tank > 0.0:
							nos_in_tank = nos_in_tank - nos_consumption_rate[nos]
							nos_boost = nos_power[nos] # We apply boost from NOS based on our Tier
						
						
					1: # Tap Button to keep on using NOS until it runs out
						if nos_in_tank >= nos_tank[nos]: # Checks if we have full tank and If not then do not allow on using NOS again
							nos_in_tank = nos_tank[nos]
							nos_lock = true
		else: # If our NOS Lock is on
			if nos_in_tank > 0.0: # Check if we have enough NOS to use
				nos_in_tank = nos_in_tank - nos_consumption_rate[nos] # Drain our NOS when in use
				nos_boost = nos_power[nos] # We apply boost from NOS based on our Tier
			elif nos_in_tank < 0.0: # If We don't have enough NOS then stop applying boost and unlock it
				nos_boost = 0.0
				nos_lock = false
			
		#//////////////////////////////////////////////////////////////////////////////////////////#
		# Hand Brake function, applies brake and stops giving power to the engine
		# If statement to check the acceleration, current gear and speed of the car
		var is_burnout = abs(acceleration) > 0.95 and veh_speed < 10.0 and gear == 1
		# Hand Brake function, applies brake and stops giving power to the engine
		if Input.is_action_pressed(key_handbrake):
			brake = 3.0
			engine_force = 0.0

			# Applies wet_grip value to make car more drifty when applying hand brake
			for i in wheels.size(): # We run through all of our wheels that are affected by hand brake and check if any is punctured
				if punctured_tires[i] == false: # If our wheel is not punctured then change its grip while holding Hand Brake to allow for drift
					wheels[i].wheel_friction_slip = wheel_grip - wet_grip # If wheel is not punctured then apply normal grip minus wet grip to imitate drift

		elif is_burnout:
			# We check if we are doing burnout and if so, dont reduce engine force but
			# change only grip of the wheels
			for i in wheels.size(): 
				if punctured_tires[i] == false: # If our wheel is not punctrued then do burnout
					wheels[i].wheel_friction_slip = burnout_slip # Apply burnout grip
		
		else: 
			# Returns back to default grip if we dont do burnout or have handbrake on
			for i in all_wheels.size(): 
				if punctured_tires[i] == false: 
					all_wheels[i].wheel_friction_slip = wheel_grip
					
					
		# Gearbox system
		match gearbox_transmission:
			
			transmission.automatic:
				
				#//////////////////////////////////////////////////////////////////////////////////#
				# Limits Negative RPM when driving in revers to prevent limitless speed
				# while driving on reverse gear, it also checks if we are cheating with gears
				# by driving off a clif and reversing in mid air while sustaining high gear
				if acceleration <= -0.00 and gear >= -1.0:
					if rpm_calclated < -100.0:
						brake = 10.0
				
				#//////////////////////////////////////////////////////////////////////////////////#
				# Gets our already calculated RPM values and Clamps it to swith gears for us
				# Here it takes our calculated RPM and clamps it
				# If our RPM reaches its max or min value, gear will be switched and we will
				# get different ratio for another gear
				# Note: We dont need to add Neutral in automatic transmission
				if rpm_calclated == clamp(rpm_calclated, 0.0, 200.0): # This should switch gears at 200 RPM or above 25km
					gear = 1
				elif rpm_calclated == clamp(rpm_calclated,  200.0,  ratio_limiter[0]):
					gear = 2
				elif rpm_calclated == clamp(rpm_calclated,  ratio_limiter[0] + 1.0, ratio_limiter[1]):
					gear = 3
				elif rpm_calclated == clamp(rpm_calclated, ratio_limiter[1] + 1.0, ratio_limiter[2]):
					gear = 4
				#//////////////////////////////////////////////////////////////////////////////#
				# Last gear. It will go beyond ratio limiter but it doesn't matter at this point
				# Note: Adding more gears will require adjustment in all 3 "Gear Ratio, Differential and Ratio Limiter"
				elif rpm_calclated == clamp(rpm_calclated, ratio_limiter[2] + 1.0, ratio_limiter[3]): 
					gear = 5
				# Small logic change by OSH QRD to allow car to have burnout
				# Checks if our RPM are on negative and if we dont push acceleration
				elif rpm_calclated == clamp(rpm_calclated, -100.0, -0.11) and acceleration < 0.0: 
					gear = -1
				
				# Check if we are rolling backwards and pressing acceleration, this will initiate burnout
				elif rpm_calclated < 0.0 and acceleration > 0.0:
					gear = 1 # Force fist gear to allow for burnout
				
				
			# Switch for manual transmission
			transmission.manual:
				
				# Plays engine sound when full throtel in neutral gear to make it more realistic
				if gear == 0 and acceleration != 0: # If we have gear 0 on manual it will not play sound unless accelerated in that gear "We actually dont need to check for Acceleration but it will throw errors in our console because it can't apply 0.0 to pitch scale
					engine_sound.pitch_scale = abs(acceleration) # We apply pitch scale to our engine sound based on our acceleration, we put it in "abs" function to give same pitch value weather we accelerate or de-accelerate "abs turns any value into positive, example abs(-50) will turn -50 into 50"
					
					
					
				#//////////////////////////////////////////////////////////////////////////////////#
				# Manual transmission system
				match shifter:
					
					false: # This is here if you dont use external shifter, gear change will be button based
						if Input.is_action_just_pressed(key_shift_up): # Default Button is Q
							if !gear == 5: # Prevents us from going above the gear limit
								gear = gear + 1 # Increase gear by 1
								brake = 10.0 # Applies brake for a second to simulate clutch
								await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
							
						elif Input.is_action_just_pressed(key_shift_down): # Default Button is A
							if !gear == -1: # Prevents us from hitting gear lower than -1 where -1 is Reverse gear
								gear = gear - 1 # Decrease gear by 1 when shifting donw
								brake = 10.0 # Applies brake for a second to simulate clutch
								await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
								
					true: # This is here in case you want to use external shifter instead of buttons
						if Input.is_action_just_pressed(key_gear_1): # This will change gear to gear 1 if external gear shaft is moved to gear 1 position
							gear = 1 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed(key_gear_2):
							gear = 2 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed(key_gear_3):
							gear = 3 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed(key_gear_4):
							gear = 4 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch1
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed(key_gear_5):
							gear = 5 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed(key_gear_reverse):
							gear = -1 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
							
				#//////////////////////////////////////////////////////////////////////////////////#
				# For Manual Gearbox only. It checks what gear it is and will
				# apply brake if RPM's are trying to go over the limit.
				# This is to prevent driving 200km on first gear and force player
				# to switch gears.
				match gear:
					-1: # Reverse gear, this one only limits our car from going above 00 RPM or 30Km in reverse
						if rpm_calclated <= -400:
							brake = 5
						
						# Prevents our car from driving forward on reverse gear
						# Technically its still possible but it driver at 0.9 RPM which is not even 1Km
						# Note this has to be applied for all gears!
						if rpm_calclated >= 0.1 and acceleration >= 0.00:
							brake = 10
					0:
						if rpm_calclated >= ratio_limiter[0]: # Checks if our RPM hits the limit then apply brakes to force gear shift
							brake = 5
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					1:
						if rpm_calclated >= ratio_limiter[0]: # Checks if our RPM hits the limit then apply brakes to force gear shift
							brake = 5
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					2:
						if rpm_calclated >= ratio_limiter[1]:
							brake = 3
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					3:
						if rpm_calclated >= ratio_limiter[2]:
							brake = 2.5
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					4:
						if rpm_calclated >= ratio_limiter[3]:
							brake = 2.5
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					5:
						#//////////////////////////////////////////////////////////////////////////#
						# Last gear. Unlike previous gears, this has no limit just like in Automatic transmission
						# Gear limits itself at a certain point on its own just like on automatic,
						# with default values its max speed should stop around 112Km roughly
						# Function below only does the same as above, which is prevents this gear
						# from driving in reverse and applies brake if car tries to drive in reverse
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
						
		_apply_torque() # Kicks in the function to apply engine power
		lights_switch() # Calls our light switch
		reset_vehicle() # Allows player to reset vehicle if needed
		
# Here is where we give our car some force
func _apply_torque() -> void:
	
	var torque : float = 0.0 # Default torque just to be safe
	
	if acceleration >= 0: # Checks if we are driving forward or reversing
		# Here is where we multiplying our acceleration by our gear ratio picked by our
		# current gear and again multiplied by our differential to give cars more power
		if energy <= 0.0: # If energy is below 0.0 we gona cut gear_ratio by drain_penalty to limit vehicle speed
			torque = acceleration * (gear_ratio[gear] / drain_penalty * differential[gear])
		else: torque = acceleration * (gear_ratio[gear] * differential[gear]) # Apply normal gear_ratio when having sufficient energy
		engine_force = torque + nos_boost # We apply our torque to our vehicle engine with addition of NOS if one is used
		
	elif acceleration == -1: # Same as above but we only take our reverse ratio and multiplying it by 50 or whatever
		torque = acceleration * (reverse_ratio * 50)
		engine_force = torque

# Our function that will make our front lights ON and OFF 
func lights_switch() -> void:
	
	# Checks if we pressed button then checks if lights are already ON or OFF
	if Input.is_action_just_pressed(key_lights): # Default key: F
		if front_light != null: # Safe check to see if we actually have front lights
			if front_light.visible == true: # If lights are visible then hide them
				front_light.hide()
			else: 
				front_light.show() # If Lights are not visible then show them


# Resets player vehicle 
func reset_vehicle() -> void:
	
	# Flips car if Reset button was pressed, Default Button: R
	if Input.is_action_pressed(key_reset) and can_reset and is_current_veh:
		can_reset = !can_reset # Switches if player can reset or not
		if energy > 5.0 and use_energy: # If we have more than 5.0 energy then drain it else don't "Same if we actually are using energy"
			energy -= 5.0
		var Y_rot = global_rotation.y # Gets our right default global Y rotation
		self.set_linear_velocity(Vector3.ZERO) # Sets our Velocity to 0
		self.set_angular_velocity(Vector3.ZERO) # Sets our angular velocity to 0 to prevent barrel rolling in case
		self.global_translate(Vector3(0, 1, 0)) # Sets our vehicle 1m above our current Y possition to prevent floor clipping
		self.set_rotation(Vector3(0, Y_rot, 0)) # Sets our rotation to global Y and flips our car, this does not affect our direction
		await get_tree().create_timer(10).timeout # Cooldown to prevent player from spamming reset button
		can_reset = !can_reset 


func add_visuals() -> void:
	
	var mod_instance = mod_list.new()  # Create an instance of the script
	# From here we instantiate all the mods that our modlist contains, everything is sorted in its own array so it can be easily modified
	# Everything can be modified from the Mod List file and does not require any changes here, just keep in mind that first mod on the list should always be the FACTORY PART of the car
	# Note: This will add the mods as a child node to our Location markers, this is here to ensure that mods are positioned correctly and always at the same place, It also makes it easier for adjusting everything while editing


	# From here we just check if we have installed the mods and change their material. Note: Use the same material as the car uses for better consistency and keep it the same.
	# To avoid any bugs and issues with colors, The main material of the part should always be in slot 0 of the material list IF it uses more than one materials since it is easier to keep it consistent for all the parts that way, you can change material order in Blender before exporting it
	if "Mod_Hood" in mod_instance: # This will check if there is Mod_Hood Array in our Mod list file, this is to prevent game from crashing if specific car will not have specific mods, you can easily restrict it for cars to have only specific parts available
		hood_location.add_child(load(mod_instance.Mod_Hood[hood_mod]["part"]).instantiate())
		if allow_color_change and hood_location.get_child_count() > 0: # Here we check if our Hood location marker have any modifications added to it, mostly to prevent crashes
			hood_location.get_child(0).get_surface_override_material(0).albedo_color = veh_color # Here we take the color of our main material of the car and apply it to out main color material in our custom par
			hood_location.get_child(0).get_surface_override_material(0).roughness = material_tint # Here we copy the tint of out material to make it consisten with car body, This will make our part matte or metalic at the same level as our car is

	# For the next two checks, same rule apply, we only change to what part we apply the color and tint and for what part we are actully looking for
	if "Mod_FBumper" in mod_instance:
		front_bumper_location.add_child(load(mod_instance.Mod_FBumper[front_bumper_mod]["part"]).instantiate())
		if allow_color_change and front_bumper_location.get_child_count() > 0:
			front_bumper_location.get_child(0).get_surface_override_material(0).albedo_color = veh_color
			front_bumper_location.get_child(0).get_surface_override_material(0).roughness = material_tint

	if "Mod_RBumper" in mod_instance:
		rare_bumper_location.add_child(load(mod_instance.Mod_RBumper[rare_bumper_mod]["part"]).instantiate())
		if allow_color_change and rare_bumper_location.get_child_count() > 0:
			rare_bumper_location.get_child(0).get_surface_override_material(0).albedo_color = veh_color
			rare_bumper_location.get_child(0).get_surface_override_material(0).roughness = material_tint
	
	if "Mod_Spoiler" in mod_instance:
		if !no_default_spoiler: # We check if this vehicle have stock spoiler
			spoiler_location.add_child(load(mod_instance.Mod_Spoiler[spoiler_mod]["part"]).instantiate()) # If car have stock spoiler model, simply add it to the car
		else:
			if spoiler_mod == 0: # If it dosen't use any spoiler by default then check if we pick first spoiler from the mod list
				if spoiler_location.get_child_count() > 0: # If we select no spoiler in case of car not having stock spoiler then check if we already have any spoiler
					spoiler_location.get_child(0).queue_free() # If we do have different spoiler and we want to remove it then simply remove any spoiler if stock is selected
			else: # In case of selecting different spoiler, simply add different one
				spoiler_location.add_child(load(mod_instance.Mod_Spoiler[spoiler_mod]["part"]).instantiate())


func modify_rims() -> void:
	
	
	# This is the system for swaping rims in car, it allows to change front and back rims independently along
	# With both sides at the same time, this also allows to color them independently or together if desired
	# In future it will also allow for a different tire texture to have different settings for it too
	# Swaping tire color and texture is planed and will be added in future along with tire marks and smoke
	# Color swap to match tire color :)
	
	if rim_list != null: # Check if we have list of rims for our car
		var rim_instance = rim_list.new() # Generates an array of our rims based on our original list
		if "Rim_list" in rim_instance: # Checks if we have any rims in our array
			
			if !use_default_rims_front: # Check if we want to use default rims or not
				all_wheels[0].get_child(0).add_child(load(rim_instance.Rim_list[front_rim_id]["part"]).instantiate()) # We place custom rims for front wheels
				all_wheels[1].get_child(0).add_child(load(rim_instance.Rim_list[front_rim_id]["part"]).instantiate())
			else:
				set_default_rims() # Jump to setting vehicle default rims
			
			
			if !use_default_rims_back:
				all_wheels[2].get_child(0).add_child(load(rim_instance.Rim_list[back_rim_id]["part"]).instantiate()) # We place custom rims for back wheels
				all_wheels[3].get_child(0).add_child(load(rim_instance.Rim_list[back_rim_id]["part"]).instantiate())
			else:
				set_default_rims()# Jump to setting vehicle default rims
			
		if separate_rim_colors: # We check if we are using separate colors or not
			
			if rim_instance.Rim_list[front_rim_id]["paintable"] == true: # We check if rims can be painted and if not then set its default colors
				all_wheels[0].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = front_rim_color
				all_wheels[1].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = front_rim_color
			else: # Assign default colors from its informations
				all_wheels[0].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[front_rim_id]["color"]
				all_wheels[1].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[front_rim_id]["color"]
			
			
			if rim_instance.Rim_list[back_rim_id]["paintable"] == true: # Same as above but we paint the back wheels for our car
				all_wheels[2].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = back_rim_color
				all_wheels[3].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = back_rim_color
			else: # Again if wheels cant be painted then fall back to predefined color in our data list
				all_wheels[2].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[back_rim_id]["color"]
				all_wheels[3].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[back_rim_id]["color"]

		
		else: # If we want to paint all rims the same color then we can use both rim color for that
			if rim_instance.Rim_list[front_rim_id]["paintable"] == true: # Again check if wheels can be painted
				all_wheels[0].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = both_rim_color
				all_wheels[1].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = both_rim_color
			else:
				all_wheels[0].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[front_rim_id]["color"]
				all_wheels[1].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[front_rim_id]["color"]
			
			
			if rim_instance.Rim_list[back_rim_id]["paintable"] == true:
				all_wheels[2].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = both_rim_color
				all_wheels[3].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = both_rim_color
			else:
				all_wheels[2].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[back_rim_id]["color"]
				all_wheels[3].get_child(0).get_child(0).get_surface_override_material(0).albedo_color = rim_instance.Rim_list[back_rim_id]["color"]
	else:
		set_default_rims() # Jump to setting vehicle default rims
	
	

func set_default_rims() -> void:
	
	if default_rims: # If we skipped custom rims then simply add default ones for our car that were assigned
		if use_default_rims_front:
			all_wheels[0].get_child(0).add_child(load(default_rims).instantiate())
			all_wheels[1].get_child(0).add_child(load(default_rims).instantiate())
		if use_default_rims_back:
			all_wheels[2].get_child(0).add_child(load(default_rims).instantiate())
			all_wheels[3].get_child(0).add_child(load(default_rims).instantiate())
	else: # IF car doesn't have default rims set then inform us about it
		print("ERROR: ", veh_name, " has no default rims set!")
		

func puncture_wheels() -> void:
	
	for i in tire_points.size(): # First we roll through all our Shapecasts to check which one are colliding
		if tire_points[i].is_colliding() and tire_points[i].get_collider(0).is_in_group("Spikes"): # We detects which Shapecast in our array is colliding with our spikes
			all_wheels[i].wheel_radius = wheel_def_radius - 0.05 # We decrease the radius of our wheel to give effect of a flat tire
			all_wheels[i].wheel_friction_slip = 0.5 # We change friction of our wheel to imitate lack of air in them
			all_wheels[i].get_child(0).rotation.x  = deg_to_rad(randi_range(5, 10)) # With this we tilt our model of the wheel in X and Z rotation to make the wheel look damaged
			all_wheels[i].get_child(0).rotation.z = deg_to_rad(randi_range(5, 10))
			punctured_tires[i] = true # We change the state of that specific wheel in our array so that Hand Break will not have an effect on our wheel
			#print(tire_points[i].name, " Hit: ", tire_points[i].get_collider(0).name)


func skiding_effects() -> void:
#//////////////////////////////////////////////////////////////////////////////////////////////#
# Here we are applying our particles under the wheels, both of these IF statements do the exact
# same thing but for each individual wheel, this is soo that if one wheel will be sliding
# it will be the only wheel to apply particles
# Checks if our Left Rare wheel is sliding (1 = not sliding) we apply that if grip is below 0.8 or 80%
# Or alternatively we check if our handbrake is pressed, then spawn particles too
	if wheels[0].get_skidinfo() < 0.8 or (Input.is_action_pressed(key_handbrake) and veh_speed > 5.0): 
		smoke_particles[0].emitting = true # We dont show particles, instead we are switching their emission to save some resources
		if skidmarks_particle.size() > 0:
			skidmarks_particle[0].emitting = true
	else: 
		smoke_particles[0].emitting = false # If we don't slide then we are not emitting anything
		if skidmarks_particle.size() > 0:
			skidmarks_particle[0].emitting = false

	# Same as above but for Right Rare wheel
	if wheels[1].get_skidinfo() < 0.8 or (Input.is_action_pressed(key_handbrake) and veh_speed > 5.0):
		smoke_particles[1].emitting = true
		if skidmarks_particle.size() > 0:
			skidmarks_particle[1].emitting = true
	else: 
		smoke_particles[1].emitting = false
		if skidmarks_particle.size() > 0:
			skidmarks_particle[1].emitting = false
			
	# This part checks if both wheels are sliding and if soo, add nitro to our tank
	if wheels[0].get_skidinfo() and wheels[1].get_skidinfo() < 0.8:
		if nos_in_tank < nos_tank[nos]: # Checks if our NOS is equal to our tank capacity and if not then add NOS when drifting
			nos_in_tank = nos_in_tank + (nos_drift_bonus * nos) # Adds NOS when drifting
		
	# This checks if any of our skidding wheels is actually sliding
	# and if soo then apply tyre sliding sound otherwise stop playing it
	# Checks if wheels are skiding or if handbrake is applied withing speed then play sound
	if (wheels[0].get_skidinfo() < 0.85 or wheels[1].get_skidinfo() < 0.85) or (Input.is_action_pressed(key_handbrake) and veh_speed > 5.0):
		# Plays tyre sound when car is sliding and if sound does not play already
		if tyre_sound.is_playing() == false:
			tyre_sound.playing = true
	else: 
		tyre_sound.stop()
