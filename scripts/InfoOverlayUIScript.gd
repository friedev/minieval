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
	if event.is_action_pressed("info_overlay") && Recap.game_over == false && isPaused == false:
		tilemap._clear_preview()
		isPaused = true
		get_tree().paused = isPaused
		palette.visible = false
		#update road labels
		$TopRowLabels/Road/RoadGP.text = str(-buildings[2].gp)
		$TopRowLabels/Road/RoadVP.text = str(buildings[2].vp)
		#update house labels
		$TopRowLabels/House/HouseGP.text = str(-buildings[11].gp)
		$TopRowLabels/House/HouseVP.text = str(buildings[11].vp)
		_set_gp_interactions("Top", buildings, "House", 11, "Shop", 12)
		_set_vp_interactions("Top", buildings, "House", 11, "Statue", 15)
		#update shop labels
		$TopRowLabels/Shop/ShopGP.text = str(-buildings[12].gp)
		$TopRowLabels/Shop/ShopVP.text = str(buildings[12].vp)
		_set_gp_interactions("Top", buildings, "Shop", 12, "House", 11)
		_set_gp_interactions("Top", buildings, "Shop", 12, "Shop", 12)
		_set_gp_interactions("Top", buildings, "Shop", 12, "Mansion", 13)
		_set_gp_interactions("Top", buildings, "Shop", 12, "Forge", 14)
		_set_vp_interactions("Top",buildings, "Shop", 12, "Cathedral", 16)
		#update mansion labels
		$TopRowLabels/Mansion/MansionGP.text = str(-buildings[13].gp)
		$TopRowLabels/Mansion/MansionVP.text = str(buildings[13].vp)
		_set_gp_interactions("Top", buildings, "Mansion", 13, "Shop", 12)
		_set_gp_interactions("Top", buildings, "Mansion", 13, "Mansion", 13)
		_set_vp_interactions("Top", buildings, "Mansion", 13, "Statue", 15)
		#update forge labels
		$TopRowLabels/Forge/ForgeGP.text = str(-buildings[14].gp)
		$TopRowLabels/Forge/ForgeVP.text = str(buildings[14].vp)
		_set_gp_interactions("Top", buildings, "Forge", 14, "Shop", 12)
		_set_gp_interactions("Top", buildings, "Forge", 14, "Forge", 14)
		_set_vp_interactions("Top", buildings, "Forge", 14, "Cathedral", 16)
		_set_vp_interactions("Top", buildings, "Forge", 14, "Keep", 17)
		#update statue labels
		$BottomRowLabels/Statue/StatueGP.text = str(-buildings[15].gp)
		$BottomRowLabels/Statue/StatueVP.text = str(buildings[15].vp)
		_set_vp_interactions("Bottom", buildings, "Statue", 15, "House", 11)
		_set_vp_interactions("Bottom", buildings, "Statue", 15, "Mansion", 13)
		_set_vp_interactions("Bottom", buildings, "Statue", 15, "Statue", 15)
		_set_vp_interactions("Bottom", buildings, "Statue", 15, "Cathedral", 16)
		#update cathedral labels
		$BottomRowLabels/Cathedral/CathedralGP.text = str(-buildings[16].gp)
		$BottomRowLabels/Cathedral/CathedralVP.text = str(buildings[16].vp)
		_set_gp_interactions("Bottom", buildings, "Cathedral", 16, "Forge", 14)
		_set_gp_interactions("Bottom", buildings, "Cathedral", 16, "Cathedral", 16)
		_set_vp_interactions("Bottom", buildings, "Cathedral", 16, "Shop", 12)
		_set_vp_interactions("Bottom", buildings, "Cathedral", 16, "Forge", 14)
		_set_vp_interactions("Bottom", buildings, "Cathedral", 16, "Statue", 15)
		_set_vp_interactions("Bottom", buildings, "Cathedral", 16, "Cathedral", 16)
		#update keep labels
		$BottomRowLabels/Keep/KeepGP.text = str(-buildings[17].gp)
		$BottomRowLabels/Keep/KeepVP.text = str(buildings[17].vp)
		_set_gp_interactions("Bottom", buildings, "Keep", 17, "Forge", 14)
		_set_gp_interactions("Bottom", buildings, "Keep", 17, "Keep", 17)
		_set_vp_interactions("Bottom", buildings, "Keep", 17, "Forge", 14)
		_set_vp_interactions("Bottom", buildings, "Keep", 17, "Keep", 17)
		_set_vp_interactions("Bottom", buildings, "Keep", 17, "Tower", 18)
		#update tower labels
		$BottomRowLabels/Tower/TowerGP.text = str(-buildings[18].gp)
		$BottomRowLabels/Tower/TowerVP.text = str(buildings[18].vp)
		_set_gp_interactions("Bottom", buildings, "Tower", 18, "Forge", 14)
		_set_vp_interactions("Bottom", buildings, "Tower", 18, "Keep", 17)
		_set_vp_interactions("Bottom", buildings, "Tower", 18, "Tower", 18)
		#update pyramid labels
		$BottomRowLabels/Pyramid/PyramidGP.text = str(-buildings[19].gp)
		$BottomRowLabels/Pyramid/PyramidVP.text = str(buildings[19].vp)
		_set_gp_interactions("Bottom", buildings, "Pyramid", 19, "Pyramid", 19)
		_set_vp_interactions("Bottom", buildings, "Pyramid", 19, "Pyramid", 19)
		for child in ui_text_layer.get_children():
			if child.name != "Timer":
				child.visible = false
		var pauseMenu = get_node(@"/root/Root/PauseMenu/Pause")
		_node_input_pause(pauseMenu)
		visible = true
	elif (event.is_action_pressed("info_overlay") || event.is_action_pressed("ui_cancel")) && Recap.game_over == false && isPaused == true:
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
		visible = false

# Pauses or unpauses input for a given node
func _node_input_pause(node):
	node.set_process_input(not node.is_processing_input())


func _set_gp_interactions(row, buildings, buildingName, buildingNumber, interactionName, interactionNumber):
	var gpInt = buildings[buildingNumber].gp_interactions[interactionNumber]
	if gpInt > 0:
		get_node(row + "RowLabels/" + buildingName + "/" + interactionName + "GPInt").text = '+' + str(gpInt)
	else:
		get_node(row + "RowLabels/" + buildingName + "/" + interactionName + "GPInt").text = str(gpInt)


func _set_vp_interactions(row, buildings, buildingName, buildingNumber, interactionName, interactionNumber):
	var vpInt = buildings[buildingNumber].vp_interactions[interactionNumber]
	if vpInt > 0:
		get_node(row + "RowLabels/" + buildingName + "/" + interactionName + "VPInt").text = '+' + str(vpInt)
	else:
		get_node(row + "RowLabels/" + buildingName + "/" + interactionName + "VPInt").text = str(vpInt)
