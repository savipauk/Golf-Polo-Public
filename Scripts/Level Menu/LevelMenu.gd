extends Node2D

var myNode : BaseButton;
var strokes : Label;

var timer: bool = false;

func popups() -> void:
	get_node("CanvasLayer").get_node("Control").visible = false;
	timer = true;
	yield(get_tree().create_timer(0.1), "timeout");
	timer = false;

func _ready():
	for entity in get_node("Levels").get_children():
		myNode = entity.get_node("TextureButton");
		var error = myNode.connect("pressed", self, "_GoToLevel", [ entity.name ]);
		if(error != OK):
			print(error);
	UpdateStrokeCounters();

func UpdateStrokeCounters() -> void:
	for entity in get_node("Levels").get_children():
		strokes = entity.get_node("Strokes");
		strokes.text = "Score: " + str(GameManager.LevelStrokes[entity.name]);
		if(GameManager.LevelStrokes[entity.name] == 0):
			strokes.text = "Not played";

func _GoToLevel(var myLevel : String):
	var level = "res://Levels/" + myLevel + ".tscn";
	
	# Go to level...
	GameManager.Strokes = 0;
	GameManager.Hole = str2var(myLevel[5]);
	var error = get_tree().change_scene(level);
	if(error != 0):
		print("ERROR: ", error);


func _on_Back_pressed():
	var error = get_tree().change_scene("res://Levels/Main.tscn");
	if(error != 0):
		print("ERROR: ", error)


func _on_Reset_pressed():
	get_node("CanvasLayer").get_node("Control").visible = true;


func _on_ResetNo_pressed():
	popups();


func _on_ResetYes_pressed():
	GameManager.InitialGameState();
	UpdateStrokeCounters();
	popups();


func _on_Random_pressed():
	var error = get_tree().change_scene("res://Levels/LevelRandom.tscn");
	if(error != 0):
		print("ERROR: ", error)
