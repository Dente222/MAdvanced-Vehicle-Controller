@icon("res://Advanced Vehicle Controller/Textures/MVehicleBody3D.png")
extends VehicleBody3D

## Vehicle Body with advanced settings and lots of customisation!

#////////////////////////////////////////////////////////////////////////////////////////////////#
# Advanced vehicle controll system for Godot 4, created by Millu30
# This vehicle controller was made with an intention to provide more advance features such as
# transmission, lights, tyre smoke, grip controll and more features while keeping it basic and
# easy to modify according to own needs/preferences, its more simply and easy to understand
# version of Vita Vehicles that utilize the VehicleBody3D and VehicleWheel3D Node.
# I tried to provide enough informations and explain what everything does for better understanding
#================================================================================================#
# Disclaimer! This might not be the most optimal way of solving some issues but it is enough
# to build around it. If there is anything that can be optimised or changer then feel free
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
# Copyright 2025 Millu30 A.K.A Gidan
#////////////////////////////////////////////////////////////////////////////////////////////////#


#////////////////////////////////////////////////////////////////////////////////////////////////#
# List of Controlls and corresponding buttons for different controllers including Sonny, XBox and Nintendo
# Arrow UP Or Right Trigger = Gas
# Arrow DOWN Or Left Trigger = Brake/Reverse
# Left/Right Arrow Or Left Joypad/Joystick = Steering
# Space Bar Or XBox A Or Sonny X = Hand Brake
# R Or XBox Y Or Sonny Triangle = Vehicle Reset
# F Or Left Stick = Front Lights
# Q Or XBox RB Or Sonny R1 = Shift UP
# A Or XBox LB Or Sonny L1 = Shift Down
# NOTE: Setup for shifter and steering wheel is not provided since it is individual to ones devices!
#////////////////////////////////////////////////////////////////////////////////////////////////#

class_name MVehicle3D # Class name for easy access in other scripts and in create node window

@export_group("Vehicle settings")
@export var veh_name : String # Sets vehicle name. Treat it as ID for custom body mods and decals. It is not necessary to use but makes it easier to restrict exclusive mods or decals for specific vehicle so they don't look missplaced
@export var is_current_veh : bool = false # Sets vehicle to be the current vehicle, sets camera and allow player to controll vehicle that has this checked on, works similar to the car swith in Need For Speed Mostwanted from 2012
@export var veh_mesh : MeshInstance3D # We take path to our vehicle mesh for future reference
@export var front_light : Node3D # Reference to front car lights [Note: We dont reference light nodes itself here, only their parrent node since we dont need that, obviously we can if we need too but not in this case]
@export var rare_lights : Node3D # Reference to rare car lights [Note: We dont reference light nodes itself here, only their parrent node since we dont need that, obviously we can if we need too but not in this case]
@export var decal_markers : Array = [Decal] # Optional if player wants to add decals to vehicle. Keep it in that order to prevent mistakes [0 = Hood, 1 = Left side, 2 = Right side, 3 = Trunk, 4 = Roof]. NOTE: Keep decals empty or simply ignore this and reference to them only when wanting to remove or replace decals 

@export_subgroup("Sounds settings")
@export var engine_pitch_modifier : float = 50 # Sets the modifier to adjust engine pitch sound accordingly
@export var engine_sound : AudioStreamPlayer3D # Reference to engine sound
@export var tyre_sound : AudioStreamPlayer3D # Reference to our tyre audio stream

@export_subgroup("Particles settings")
@export var smoke_particles : Array [GPUParticles3D] # Array of our particle nodes for easy access

@export_subgroup("Colour settings")
@export var allow_color_change : bool = true # We check if Player is allowed to change vehicle colour or not, you can restrict some vehicle from their colour to be changed if necessary
@export var material_id : int = 1 # This determines which overrided material we wanna change colour of, my vehicles have 2 materials "0: for windows and details, and 1: for actuall body colour of the vehicle" this way we determine which material we wanna change and prevent from changing wrong material 
@export_color_no_alpha var veh_color : Color = "#ffffff" # We set our color for vehicle here "Default is White" We apply this then directly add it to our veh_mesh and override material albedo with our albedo colour NOTE: Car should not use any color texture, if you want to use premade texture on it then dissable Allow Colour Change!

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

@export_group("Vehicle Energy settings")
@export var use_energy : bool = true # Checks if we should use energy or not
@export var max_energy : float = 150.0 # Max Energy capacity we can have
@export var energy_consumption_rate : float = 0.01 # Rate in which we gonna consume energy from our vehicle
@export_range(1, 10) var drain_penalty : int = 6 # Penalty that will be applie to gear_ratio when we run out of energy

@export_group("Wheels settings")
@export_range(0,3) var wheel_grip : float = 3.0 # Default grip for wheels this will always be the value set in _ready() function
@export_range(0,3) var wet_grip : float = 2.0 # Modifier for penalty on wet surface, "closer to wheel_grip, More drifty it becomse!" Used for handbreak but can also be used in the environment if desired
@export var wheels : Array [VehicleWheel3D] # Array of all wheels that player wants to apply wet_grip modifier
@export var all_wheels : Array [VehicleWheel3D] # Array of all car wheels in case we want to apply different grip based on map setting to all wheels



var acceleration : float # Controlls value of acceleration, range from -1 to 1. Note: this support controllers too!
var veh_speed : float # Displays Vehicle speed, not very accurate but can be adjusted below
const speed_modifier : float = 2.8 # Modifies actuall speed to be more accurate on speed o metter
var gear : int = 0 # Displays current gear based on gear_ratio
var can_reset : bool = true # Switch to allow player to reset vehicle and set cooldown to prevent spamming it
var energy : float # Variable in which we store vehicle energy or fuel and exports it to progress bar in UI scene
var camera_scene : = preload("res://Advanced Vehicle Controller/Scenes/cam_holder.tscn").instantiate() # We Instantiate our vehicle main camera and add it to our vehicle as a child node
var minimap : = preload("res://Advanced Vehicle Controller/Scenes/MinimapCamera.tscn").instantiate() # We Instantiate our Minimap Scene and add it to our vehicle as a child node, this will create camera above our car and add necessary markers to id also adds smal display for our minimap

# Everything that needs to be set when our car is initiated
func _ready() -> void:
	
	
	if allow_color_change and veh_mesh.get_surface_override_material(material_id): # If player is allowed to change colour of this specific vehicle
		veh_mesh.get_surface_override_material(material_id).albedo_color = veh_color # We get our material that controlls vehicle color and change its albed to our albedo value
	
	if is_current_veh: # Sets viewport to use provided camera. Read comment on is_current_veh variable to learn more
		# We preload our scene containing camera and instantiate it
		# then we add it as a child node to our car but only if this is the car we want to drive
		# otherwise camera will not be attached
		energy = max_energy # We set vehicle energy to its max limit soo it is full
		Ui.get_node("ProgressBar").max_value = max_energy
		self.add_child(camera_scene) # Adds preloaded and instantiated camera scene to our car
		self.add_child(minimap) # Adds Minimap to the vehicle we controll
		engine_sound.playing = true
		
		for x in all_wheels: # Sets the default grip for all the wheels that are in variable
				x.wheel_friction_slip = wheel_grip

# Everything that is triggered on Physical CPU Ticks
func _physics_process(delta: float) -> void:
	
	var speed # Our Speed variable reference
	var rpm # RPM reference
	var rpm_calclated # Calculated RPM reference
	acceleration = 0.0 # We will be setting acceleration to 0.0 on every physical tick just in case
	
	
	#//////////////////////////////////////////////////////////////////////////////////////////////#
	# Here we are applying our particles under the wheels, both of these IF statements do the exact
	# same thing but for each individual wheel, this is soo that if one wheel will be sliding
	# it will be the only wheel to apply particles
	if wheels[0].get_skidinfo() < 0.8: # Checks if our Left Rare wheel is sliding (1 = not sliding) we apply that if grip is below 0.8 or 80%
		smoke_particles[0].emitting = true # We dont show particles, instead we are switching their emission to save some resources
	else: 
		smoke_particles[0].emitting = false # If we don't slide then we are not emitting anything
	
	# Same as above but for Right Rare wheel
	if wheels[1].get_skidinfo() < 0.8:
		smoke_particles[1].emitting = true
	else: 
		smoke_particles[1].emitting = false
		
		
	# This checks if any of our skidding wheels is actually sliding
	# and if soo then apply tyre sliding sound otherwise stop playing it
	if wheels[0].get_skidinfo() < 0.85 or wheels[1].get_skidinfo() < 0.85:
		play_tyre_sound() # Playes tyre skidding sound when drifiting
	else: tyre_sound.stop()
	
	
	# Applies basic controlls and displays informations of currently driveable vehicle
	# if vehicle is not selected as main one then it will not provide any info for player
	# also player will not be able to controll it
	if is_current_veh:
		var velocity_xz = Vector3(linear_velocity.x, 0, linear_velocity.z) # Gets linear velocity of our vehicle in X/Z axis to calculate speed NOTE: We are ignoring Y axis here soo no sound neither speed will be calculated when car will be falling off in Y axis only
		speed = velocity_xz.length() # Calculates linear velocity of our vehicle to be used in Speed o meter and engine sound
		steering = lerp(steering, Input.get_axis("Right", "Left") * 0.4, 5 * delta) # Allows our vehicle to turn. Note: This already supports gamepad!
		acceleration = Input.get_axis("Brake", "Acceleration") # Allows our car to move forward and reverse. Controller supported!
		veh_speed = speed * speed_modifier # Gets vehicle velocity and multiplies it to get semi accurate velocity display on speed o meter, adjustable
		rpm = rpm_wheel.get_rpm() # Gets RPM from our selected wheel
		rpm_calclated = clamp(rpm, -max_rpm * gear_ratio[gear], max_rpm * gear_ratio[gear]) # Gets our RPM and calculate it to have max negative RPM and positive RPM to limit our geabox and overall power
		#print("My Steering: " + str(steering))
		
		
		if !use_energy: # We check if our vehicle uses energy and if not then Hide the bar
			Ui.get_node("ProgressBar").visible = false
		
		# If we have more energy and our acceleration is not 0.0 then drain energy
		# We check for acceleration to prevent car from loosing energy when in mid air
		# We also check if we do use energy "Used for different gamemodes when needed"
		if energy > 0.0 and use_energy:
			if acceleration != 0.0:
				energy -= energy_consumption_rate # We gonna decrease energy by its consumption rate every physical frame we are making our car drive
		
		
		# Some On Screen debug stats to track whats going on with our car
		Ui.get_node("VBoxContainer/Acceleration").text = "Acceleration: " + str(acceleration)
		if gear == -1: # This one checks if our gear is -1 "Reverse" and if soo then change icon to R, otherwise display gears properly
			Ui.get_node("VBoxContainer/Gear Shaft").text = "Gear: R"
		elif gear == 0: 
			Ui.get_node("VBoxContainer/Gear Shaft").text = "Gear: N"
		else: Ui.get_node("VBoxContainer/Gear Shaft").text = "Gear: " + str(gear)
		Ui.get_node("VBoxContainer/Absolute RPM").text = "Absolute RPM: " + str(roundi(veh_speed)) + " KMPH"
		Ui.get_node("VBoxContainer/Max RPM").text = "Current Engine Force: " + str(engine_force) + " Multiplied by: " + str(gear_ratio[gear])
		Ui.get_node("VBoxContainer/Info").text = "Current RPM: " + str(rpm_calclated)
		Ui.get_node("ProgressBar").value = energy
		
		engine_sound.pitch_scale = speed/engine_pitch_modifier + 0.1 # Sets the pitch of our vehicle engine sound based on its velocity
		
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
		# Hand Brake function, applies brake and stops giving power to the engine
		# Also supports gamepad
		if Input.is_action_pressed("Hand Brake"):
			brake = 3.0
			engine_force = 0.0
			
			# Applies wet_grip value to make car more drifty when applying hand brake
			for x in wheels:
				x.wheel_friction_slip = wheel_grip - wet_grip
			
		else: # Same as above but sets wheel grip back to default when releasing hand brake
			for x in all_wheels:
				x.wheel_friction_slip = wheel_grip
		
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
				elif rpm_calclated == clamp(rpm_calclated, ratio_limiter[2] + 1, ratio_limiter[3]): 
					gear = 5
					# Reverse gear checks if our RPM are below -0.11 then changes the gear to make it more consistent
				elif rpm_calclated == clamp(rpm_calclated, -100.0, -0.11):
					gear = -1
					
			# Switch for manual transmission
			transmission.manual:
				
				# Plays engine sound when full throtel in neutral gear to make it more realistic
				if gear == 0 and acceleration != 0: # If we have gear 0 on manual it will not play sound unless accelerated in that gear "We actually dont need to check for Acceleration but it will throw errors in our console because it can't apply 0.0 to pitch scale
					engine_sound.pitch_scale = abs(acceleration) # We apply pitch scale to our engine sound based on our acceleration, we put it in "abs" function to give same pitch value weather we accelerate or de-accelerate "abs turns any value into positive, example abs(-50) will turn -50 into 50"
					
				#//////////////////////////////////////////////////////////////////////////////////#
				# Manual transmission system
				match shifter:
					
					false: # This is here if you dont use external shifter, gear change will be button based
						if Input.is_action_just_pressed("shift_up"): # Default Button is Q
							if !gear == 5: # Prevents us from going above the gear limit
								gear = gear + 1 # Increase gear by 1
								brake = 10.0 # Applies brake for a second to simulate clutch
								await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
							
						elif Input.is_action_just_pressed("shift_down"): # Default Button is A
							if !gear == -1: # Prevents us from hitting gear lower than -1 where -1 is Reverse gear
								gear = gear - 1 # Decrease gear by 1 when shifting donw
								brake = 10.0 # Applies brake for a second to simulate clutch
								await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
								
					true: # This is here in case you want to use external shifter instead of buttons
						if Input.is_action_just_pressed("Gear 1"): # This will change gear to gear 1 if external gear shaft is moved to gear 1 position
							gear = 1 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed("Gear 2"):
							gear = 2 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed("Gear 3"):
							gear = 3 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed("Gear 4"):
							gear = 4 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed("Gear 5"):
							gear = 5 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
						if Input.is_action_just_pressed("Gear Reverse"):
							gear = -1 # Set Gear
							brake = 10.0 # Applies brake for a second to simulate clutch
							await get_tree().create_timer(10.0).timeout # Prevents from switching gears instantly
							
				#//////////////////////////////////////////////////////////////////////////////////#
				# For Manual Gearbox only. It checks what gear it is and will
				# apply brake if RPM's are trying to go over the limit.
				# This is to prevent driving 200km on first gear and force player
				# to switch gears.
				match gear:
					-1: # Reverse gear, this one only limits our car from going above 100 RPM or 13Km in reverse
						if rpm_calclated <= -100:
							brake = 5
						else: brake = 0.0
						
						# Prevents our car from driving forward on reverse gear
						# Technically its still possible but it driver at 0.9 RPM which is not even 1Km
						# Note this has to be applied for all gears!
						if rpm_calclated >= 0.1 and acceleration >= 0.00:
							brake = 10
					0:
						if rpm_calclated >= manual_ratio_limiter[0]: # Checks if our RPM hits the limit then apply brakes to force gear shift
							brake = 5
						else: brake = 0.0
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					1:
						if rpm_calclated >= manual_ratio_limiter[0]: # Checks if our RPM hits the limit then apply brakes to force gear shift
							brake = 5
						else: brake = 0.0
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					2:
						if rpm_calclated >= manual_ratio_limiter[1]:
							brake = 3
						else: brake = 0.0
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					3:
						if rpm_calclated >= manual_ratio_limiter[2]:
							brake = 2.5
						else: brake = 0.0
						
						if rpm_calclated <= 0.00 and acceleration <= -0.11:
							brake = 10
					4:
						if rpm_calclated >= manual_ratio_limiter[3]:
							brake = 2.5
						else: brake = 0.0
						
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
		engine_force = torque # We apply our torque to our vehicle engine
		
	elif acceleration == -1: # Same as above but we only take our reverse ratio and multiplying it by 50 or whatever
		torque = acceleration * (reverse_ratio * 50)
		engine_force = torque

# Our function that will make our front lights ON and OFF 
func lights_switch() -> void:
	
	# Checks if we pressed button then checks if lights are already ON or OFF
	if Input.is_action_just_pressed("lights"): # Default key: F
		if front_light.visible == true: # If lights are visible then hide them
			front_light.hide()
		else: front_light.show() # If Lights are not visible then show them
	pass


# Resets player vehicle 
func reset_vehicle() -> void:
	
		# Flips car if Reset button was pressed, Default Button: R
	if Input.is_action_pressed("Reset") and can_reset and is_current_veh:
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

# Plays tyre sound when car is sliding and if sound does not play already
func play_tyre_sound() -> void:
	if tyre_sound.is_playing() == false:
		tyre_sound.playing = true

#func _unhandled_input(event: InputEvent) -> void: # Debug purpose use only to check what Imput device is in what order
	#print(Input.get_joy_name(1))
	#pass
