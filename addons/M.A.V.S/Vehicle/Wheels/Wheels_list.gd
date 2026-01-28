extends Resource

# Here is our list of all the rims we can have in game with their respective settings like
# Name, Path to the model, Price, Paintability

var Rim_list : Array = [
	{
		"name" : "Royal", # Name of the rims
		"part" : "res://addons/M.A.V.S/Vehicle/Wheels/rim_royal.tscn", # Path to the rims
		"price" : int(0), # Price for the rims
		"paintable" : bool(true), # If player is allowed to paint these rims or not, if not then skip painting option
		"color" : Color(0.638, 0.638, 0.638, 1.0), # Allows to change the color manually here for default
		"materials" : int(2) # Number of materials it contains
	},
	{
		"name" : "Astra", # Name of the rims
		"part" : "res://addons/M.A.V.S/Vehicle/Wheels/rim_astra.tscn", # Path to the rims
		"price" : int(0), # Price for the rims
		"paintable" : bool(true), # If player is allowed to paint these rims or not, if not then skip painting option
		"color" : Color(0.638, 0.638, 0.638, 1.0), # Allows to change the color manually here for default
		"materials" : int(2)# Number of materials it contains
	}
	
	
	
	
]
