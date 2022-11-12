extends Node

# Timer because control nodes stack on top of each other
# if you press on the top one, the bottom one will get pressed as well

var timer := false;

func _on_PlayCustomLevel_pressed():
	if(timer):
		return;
	get_node("CanvasLayer").get_node("FileDialog").popup();

func _on_Play_pressed():
	if(timer):
		return;
	var error = get_tree().change_scene("res://Levels/LevelMenu.tscn");
	if(error != 0):
		print("ERROR: ", error);

func _on_LevelEditor_pressed():
	if(timer):
		return;
	get_node("CanvasLayer2").get_node("Control").visible = true;

func popups() -> void:
	get_node("CanvasLayer2").get_node("Control").visible = false;
	timer = true;
	yield(get_tree().create_timer(0.1), "timeout");
	timer = false;

func _on_NewCustom_pressed():
	var error = get_tree().change_scene("res://Levels/LevelEditor.tscn");
	if(error != 0):
		print("ERROR: ", error);

func _on_LoadCustom_pressed():
	popups();
	get_node("CanvasLayer3").get_node("FileDialog").popup();

func _on_Cancel_pressed():
	popups();
