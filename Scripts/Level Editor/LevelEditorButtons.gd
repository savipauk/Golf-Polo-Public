extends Node

var floors;
var walls;
var spawnOffset = Vector2(0, -8);

func _ready():
	var root = get_tree().get_root().get_node("LevelEditor");
	floors = root.get_node("Floor");
	walls = root.get_node("Walls");

func LoadInstance(path, wall):
	var scene = load(path);
	var instance = scene.instance();
	
	var entityExtents;
	var entityPos;
	var myExtents;
	
	if(wall):
		get_tree().get_root().get_node("LevelEditor").get_node("Walls").add_child(instance);
		myExtents = Vector2(4, 16);
	else:
		get_tree().get_root().get_node("LevelEditor").get_node("Floor").add_child(instance);
		myExtents = Vector2(16, 16);
	
	# get proper position -> 0 do width po gridzie 640
	# gameheight to height po gridiize 360
	var foundPos := false;
	var pos;
	
	for i in range (16, 640, 32):
		for j in range (GameManager.GUIHeight + 16, 360, 32):
			var taken := false;
			pos = Vector2(i, j);
			
			for entity in (floors.get_children() + walls.get_children()):
				entityExtents = entity.get_node("Selection").get_node("CollisionShape2D").shape.extents;
				entityExtents *= entity.scale;
				entityPos = entity.global_position;
				
				if(pos.x - myExtents.x < entityPos.x + entityExtents.x && pos.x + myExtents.x > entityPos.x - entityExtents.x):
					if(pos.y - myExtents.y < entityPos.y + entityExtents.y && pos.y + myExtents.y > entityPos.y - entityExtents.y):
						taken = true;
				
			if(!taken):
				foundPos = true;
				instance.set_position(Vector2(i, j).snapped(Vector2(16, 16)) + spawnOffset);
				break;
		if(foundPos):
			break;
	
	if(!foundPos):
		instance.queue_free();

func _on_Ice_pressed():
	LoadInstance("res://Objects/LevelEditor/IceLevelEditor.tscn", false);


func _on_Sand_pressed():
	LoadInstance("res://Objects/LevelEditor/SandLevelEditor.tscn", false);


func _on_Wall_pressed():
	LoadInstance("res://Objects/LevelEditor/WallLevelEditor.tscn", true);


func _on_ToMainMenu_pressed():
	get_tree().get_root().get_node("LevelEditor").queue_free();
	var error = get_tree().change_scene("res://Levels/Main.tscn");
	if(error != 0):
		print("ERROR: ", error);
