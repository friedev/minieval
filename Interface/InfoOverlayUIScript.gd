extends Control

var isPaused = false

# Make score report overlay appear when user holds shift
func _input(event):
	var tilemap = get_node(@"/root/Root/TileMap")
	var buildings = tilemap.BUILDINGS
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
	var Recap = get_node(@"/root/Root/RecapUI/Control")
	if event.is_action_pressed("info_overlay") && Recap.game_over == false:
		tilemap._clear_preview()
		isPaused = true
		get_tree().paused = isPaused
		palette.visible = false
		#update road labels
		get_node("TopRowLabels/Road/RoadCost").text = str(buildings[2].cost)
		get_node("TopRowLabels/Road/RoadVPGain").text = str(buildings[2].vp)
		get_node("TopRowLabels/Road/RoadCostIncrement").text = "(+" + str(buildings[2].cost_increment) + ")"
		get_node("TopRowLabels/Road/RoadVPIncrement").text = "(+" + str(buildings[2].vp_increment) + ")"
		#update house labels
		get_node("TopRowLabels/House/HouseCost").text = str(buildings[11].cost)
		get_node("TopRowLabels/House/HouseVPGain").text = str(buildings[11].vp)
		get_node("TopRowLabels/House/HouseCostIncrement").text = "(+" + str(buildings[11].cost_increment) + ")"
		get_node("TopRowLabels/House/HouseVPIncrement").text = "(+" + str(buildings[11].vp_increment) + ")"
		#update shop labels
		get_node("TopRowLabels/Shop/ShopCost").text = str(buildings[12].cost)
		get_node("TopRowLabels/Shop/ShopVPGain").text = str(buildings[12].vp)
		get_node("TopRowLabels/Shop/ShopCostIncrement").text = "(+" + str(buildings[12].cost_increment) + ")"
		get_node("TopRowLabels/Shop/ShopVPIncrement").text = "(+" + str(buildings[12].vp_increment) + ")"
		#update big house labels
		get_node("TopRowLabels/BigHouse/BigHouseCost").text = str(buildings[13].cost)
		get_node("TopRowLabels/BigHouse/BigHouseVPGain").text = str(buildings[13].vp)
		get_node("TopRowLabels/BigHouse/BigHouseCostIncrement").text = "(+" + str(buildings[13].cost_increment) + ")"
		get_node("TopRowLabels/BigHouse/BigHouseVPIncrement").text = "(+" + str(buildings[13].vp_increment) + ")"
		#update forge labels
		get_node("TopRowLabels/Forge/ForgeCost").text = str(buildings[14].cost)
		get_node("TopRowLabels/Forge/ForgeVPGain").text = str(buildings[14].vp)
		get_node("TopRowLabels/Forge/ForgeCostIncrement").text = "(+" + str(buildings[14].cost_increment) + ")"
		get_node("TopRowLabels/Forge/ForgeVPIncrement").text = "(+" + str(buildings[14].vp_increment) + ")"
		#update field labels
		get_node("BottomRowLabels/Field/FieldCost").text = str(buildings[15].cost)
		get_node("BottomRowLabels/Field/FieldVPGain").text = str(buildings[15].vp)
		get_node("BottomRowLabels/Field/FieldCostIncrement").text = "(+" + str(buildings[15].cost_increment) + ")"
		get_node("BottomRowLabels/Field/FieldVPIncrement").text = "(+" + str(buildings[15].vp_increment) + ")"
		#update cathedral labels
		get_node("BottomRowLabels/Cathedral/CathedralCost").text = str(buildings[16].cost)
		get_node("BottomRowLabels/Cathedral/CathedralVPGain").text = str(buildings[16].vp)
		get_node("BottomRowLabels/Cathedral/CathedralCostIncrement").text = "(+" + str(buildings[16].cost_increment) + ")"
		get_node("BottomRowLabels/Cathedral/CathedralVPIncrement").text = "(+" + str(buildings[16].vp_increment) + ")"
		#update keep labels
		get_node("BottomRowLabels/Keep/KeepCost").text = str(buildings[17].cost)
		get_node("BottomRowLabels/Keep/KeepVPGain").text = str(buildings[17].vp)
		get_node("BottomRowLabels/Keep/KeepCostIncrement").text = "(+" + str(buildings[17].cost_increment) + ")"
		get_node("BottomRowLabels/Keep/KeepVPIncrement").text = "(+" + str(buildings[17].vp_increment) + ")"
		#update tower labels
		get_node("BottomRowLabels/Tower/TowerCost").text = str(buildings[18].cost)
		get_node("BottomRowLabels/Tower/TowerVPGain").text = str(buildings[18].vp)
		get_node("BottomRowLabels/Tower/TowerCostIncrement").text = "(+" + str(buildings[18].cost_increment) + ")"
		get_node("BottomRowLabels/Tower/TowerVPIncrement").text = "(+" + str(buildings[18].vp_increment) + ")"
		#update pyramid labels
		get_node("BottomRowLabels/Pyramid/PyramidCost").text = str(buildings[19].cost)
		get_node("BottomRowLabels/Pyramid/PyramidVPGain").text = str(buildings[19].vp)
		get_node("BottomRowLabels/Pyramid/PyramidCostIncrement").text = "(+" + str(buildings[19].cost_increment) + ")"
		get_node("BottomRowLabels/Pyramid/PyramidVPIncrement").text = "(+" + str(buildings[19].vp_increment) + ")"
		for child in ui_text_layer.get_children():
			if child.name != "Timer":
				child.visible = false
		var pauseMenu = get_node(@"/root/Root/PauseMenu/Pause")
		_node_input_pause(pauseMenu)
		var stats = get_node(@"/root/Root/StatsOverlay/Control")
		_node_input_pause(stats)
		visible = true
	elif event.is_action_released("info_overlay") && Recap.game_over == false:
		isPaused = false
		get_tree().paused = isPaused
		palette.visible = true
		for child in ui_text_layer.get_children():
			if child.name != "Timer":
				child.visible = true
		if Global.game_mode > 0:
			turn_label.visible = false
		var pauseMenu = get_node(@"/root/Root/PauseMenu/Pause")
		_node_input_pause(pauseMenu)
		var stats = get_node(@"/root/Root/StatsOverlay/Control")
		_node_input_pause(stats)
		visible = false

#pauses input for a given node
func _node_input_pause(node):
	var nodeInput = node.is_processing_input()
	node.set_process_input(!nodeInput)
