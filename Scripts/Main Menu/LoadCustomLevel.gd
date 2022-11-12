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
	
	file.close();
	
	LoadLevel(text);

func LoadLevel(text) -> void:
	var data = { };
	data = parse_json(text);
	
	var scene = preload("res://Levels/LevelPreset.tscn");
	var instance = scene.instance();
	
	instance.get_node("Player").position = Vector2(str2var(data["PlayerPosition"]));
	instance.get_node("Hole").position = Vector2(str2var(data["HolePosition"]));
	
	var entities = { };
	entities = data["Entities"];
	for entity in entities:
		var position = entity["Position"];
		var size = entity["Size"];
		var type = entity["Type"]
		var rotation = entity["Rotation"];
		var object;
		if(type == "wall"):
			object = load("res://Objects/Game/Wall.tscn").instance();
		else:
			var player = instance.get_node("Player");
			var enteredFunction;
			var exitedFunction
			if(type == "sand"):
				object = load("res://Objects/Game/Sand.tscn").instance();
				enteredFunction = "_on_Sand_body_entered";
				exitedFunction = "_on_Sand_body_exited";
			else:
				object = load("res://Objects/Game/Ice.tscn").instance();
				enteredFunction = "_on_Ice_body_entered";
				exitedFunction = "_on_Ice_body_exited";
			# Read connect() documentation
			# CONNECT_PERSIST needed for saving levels as .tscn to use as in-game levels
			# (using LevelEditor as a level maker)
			# GameManager -> input
			object.connect("body_entered", player, enteredFunction, [], CONNECT_PERSIST);
			object.connect("body_exited", player, exitedFunction, [], CONNECT_PERSIST);
		
		object.scale = str2var(size);
		object.position = str2var(position);
		object.rotation = deg2rad(str2var(rotation));
		
		instance.add_child(object);
	
	get_tree().get_root().add_child(instance);
	get_tree().get_root().get_node("MainMenu").queue_free();
