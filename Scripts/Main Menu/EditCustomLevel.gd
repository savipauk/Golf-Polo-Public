extends FileDialog

func _on_FileDialog_file_selected(path):
	var file = File.new();
	
	if(!file.file_exists(path)):
		return;
	
	var error = file.open(path, File.READ);
	if(error != OK):
		file.close();
		return;
	
	var text = file.get_as_text();
	
	var faultCheck = JSON.parse(text);
	if(faultCheck.error != OK):
		file.close();
		return;
	
	var data = { };
	data = parse_json(text);
	file.close();
	
	var scene = preload("res://Levels/LevelEditor.tscn");
	var instance = scene.instance();
	
	instance.get_node("PseudoPlayer").position = Vector2(str2var(data["PlayerPosition"]));
	instance.get_node("Hole").position = Vector2(str2var(data["HolePosition"]));
	
	var entities = data["Entities"];
	for entity in entities:
		var position = entity["Position"];
		var size = entity["Size"];
		var type = entity["Type"]
		var rotation = entity["Rotation"];
		
		var object;
		if(type == "wall"):
			object = load("res://Objects/LevelEditor/WallLevelEditor.tscn").instance();
		elif(type == "sand"):
			object = load("res://Objects/LevelEditor/SandLevelEditor.tscn").instance();
		else:
			object = load("res://Objects/LevelEditor/IceLevelEditor.tscn").instance();
		
		object.scale = str2var(size);
		object.position = str2var(position);
		object.rotation = deg2rad(str2var(rotation));
		
		if(type == "wall"):
			instance.get_node("Walls").add_child(object);
		else:
			instance.get_node("Floor").add_child(object);
	
	get_tree().get_root().add_child(instance);
	get_tree().get_root().get_node("MainMenu").queue_free();
