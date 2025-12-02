extends Resource

# List of parts for each mod in our car, they have to be preloaded but only when used, otherwise it will not work
# Array can be easily modified but keep the factory mods as the first part in each array!
# This rule apply to all the arrays!

# Slight modification for holding better data for each part
# This include part name and its price for future reference in game
var Mod_Hood : Array = [
	{
		"name": "Factory Part", # This refers to part name that will be displayed in game shop if one adds one
		"part": "res://addons/M.A.V.S/Vehicle/Cleo V8/Tune Parts/Hood_Default.tscn", # Actual part model
		"price": int(0) # Default price for the part, keep stock parts at 0, we keep the price as intager just in case
	},
	{
		"name": "Custom Hood",
		"part": "res://addons/M.A.V.S/Vehicle/Cleo V8/Tune Parts/Hood_Custom.tscn",
		"price": int(250)
	}
]

var Mod_FBumper : Array = [ # This array holds all parts for Front Bumpers
	{
		"name": "Factory Part",
		"part": "res://addons/M.A.V.S/Vehicle/Cleo V8/Tune Parts/Front_Default_Bumper.tscn",
		"price": int(0)
	},
	{
		"name": "Custom Front Bumper",
		"part": "res://addons/M.A.V.S/Vehicle/Cleo V8/Tune Parts/Front_Bumper_Custom.tscn",
		"price": int(250)
	}
]


var Mod_RBumper : Array = [ # This array holds all parts for Rare Bumpers
		{
		"name": "Factory Part",
		"part": "res://addons/M.A.V.S/Vehicle/Cleo V8/Tune Parts/Rare_Default_Bumper.tscn",
		"price": int(0)
	},
	{
		"name": "Custom Back Bumper",
		"part": "res://addons/M.A.V.S/Vehicle/Cleo V8/Tune Parts/Rare_Custom_Bumper.tscn",
		"price": int(250)
	}	
]
