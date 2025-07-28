extends Resource

# List of parts for each mod in our car, they have to be preloaded but only when used, otherwise it will not work
# Array can be easily modified but keep the factory mods as the first part in each array!
# This rule apply to all the arrays!
var Mod_Hood : Array = [ # This array is for Hood mods on our car
	preload("res://Advanced Vehicle Controller/Vehicle/Cleo V8/Tune Parts/Hood_Default.tscn"), # Factory Part of the car
	preload("res://Advanced Vehicle Controller/Vehicle/Cleo V8/Tune Parts/Hood_Custom.tscn") # Custom part for our car
]

var Mod_FBumper : Array = [ # This array holds all parts for Front Bumpers
	preload("res://Advanced Vehicle Controller/Vehicle/Cleo V8/Tune Parts/Front_Default_Bumper.tscn"),
	preload("res://Advanced Vehicle Controller/Vehicle/Cleo V8/Tune Parts/Front_Bumper_Custom.tscn")
]

var Mod_RBumper : Array = [ # This array holds all parts for Rare Bumpers
	preload("res://Advanced Vehicle Controller/Vehicle/Cleo V8/Tune Parts/Rare_Default_Bumper.tscn"),
	preload("res://Advanced Vehicle Controller/Vehicle/Cleo V8/Tune Parts/Rare_Custom_Bumper.tscn")
]
