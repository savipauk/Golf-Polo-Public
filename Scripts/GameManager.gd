extends Node

var Strokes = 0; # Temporary strokes value (current level or previous level strokes)
var Power = 0;
var Hole = 1;

var LevelStrokes = {}; # Permanent strokes value

var GUIHeight = 40;
var gridSize = 8;

var devbuild: bool = true;

func FinishLevel(var levelName : String) -> void:
	var error;
	# Strokes = 0;
	if(levelName != "LevelPreset"):
		if(Strokes < LevelStrokes[levelName] || LevelStrokes[levelName] == 0):
			LevelStrokes[levelName] = Strokes;
			SaveGameProgress();
		error = get_tree().change_scene("res://Levels/LevelMenu.tscn");
	else:
		get_tree().get_root().get_node("LevelPreset").queue_free();
		error = get_tree().change_scene("res://Levels/Main.tscn");
	
	Strokes = 0;
	
	if(error != 0):
		print("ERROR: ", error);


# Saving level progress

func SaveGameProgress() -> void:
	var file = File.new();
	
	var error = file.open(path, File.WRITE);
	if(error == OK):
		file.store_line(to_json(LevelStrokes));
		file.close();

var path = "user://savefile.golf";

func _ready():
	# Create CustomLevels directory if it doesn't exist
	var saveDir = "user://CustomLevels/";
	var dir = Directory.new();
	if(!dir.dir_exists(saveDir)):
		dir.make_dir_recursive(saveDir);
	
	# Check if savefile file exists
	# if yes -> load game save
	# if no -> initialize game state
	
	var file = File.new();
	if(file.file_exists(path)):
		LoadGameState();
	else:
		InitialGameState();
	file.close();

func InitialGameState() -> void:
	for i in 10:
		var key: String = "Level" + String(i + 1);
		LevelStrokes[key] = 0;
	
	SaveGameProgress();

func LoadGameState() -> void:
	var file = File.new();
	# Mora postojati jer smo vec prije provjerili
	
	var error = file.open(path, File.READ);
	if(error != OK):
		file.close();
		InitialGameState();
		return;
	
	var text = file.get_as_text();
	
	var faultCheck = JSON.parse(text);
	if(faultCheck.error != OK):
		file.close();
		InitialGameState();
		return;
	
	LevelStrokes = parse_json(text);
	file.close();
	

func _input(event):
	if(!devbuild):
		return;
	
	if(!get_tree().get_root().get_node_or_null("LevelPreset")):
		return;
	
	if(event is InputEventKey && event.is_action_pressed("rotatewallkey")):
		var level = get_tree().get_root().get_node("LevelPreset");
		for entity in level.get_children():
			entity.owner = level;
		var packed_scene = PackedScene.new();
		var error = packed_scene.pack(level);
		if(error == OK):
			var Rerror = ResourceSaver.save("res://my_scene.tscn", packed_scene);
			if(Rerror != OK):
				print(Rerror);
