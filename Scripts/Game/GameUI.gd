extends Control

func _process(_delta):
	$HoleNumber.text = "Level: " + str(GameManager.Hole);
	$Power.text = "Power: " + str(round(GameManager.Power));
	$Strokes.text = "Strokes: " + str(GameManager.Strokes);
	
	if(get_tree().get_root().get_node_or_null("LevelPreset")):
		$HoleNumber.text = "Level: Custom";


func _on_ToMainMenu_pressed():
	var error = get_tree().change_scene("res://Levels/Main.tscn");
	if(error != 0):
		print("ERROR: ", error);
	if(get_tree().get_root().get_node_or_null("LevelPreset")):
		get_tree().get_root().get_node("LevelPreset").queue_free();
