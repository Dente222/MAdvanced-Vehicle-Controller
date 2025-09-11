extends Area3D

@export var traffic_lanes : Array[Path3D]



func _on_area_entered(area: Area3D) -> void:
	await get_tree().create_timer(0.2).timeout
	var entered_traffic = area.get_parent()
	var selected_lane = traffic_lanes.pick_random()
	print(selected_lane)
	entered_traffic.reparent(selected_lane)
	entered_traffic.progress = 0.0
	
