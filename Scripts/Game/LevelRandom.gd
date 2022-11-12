extends Node2D

onready var wallSorter = get_node("Walls");
var spawnOffset = Vector2(0, -8); # how much to move next item on create

var width = 11; # 11 walls wide because offset to give player more room, otherwise 20
var height = 10; # 10 walls tall

var ran = RandomNumberGenerator.new();

onready var Hole: Node2D = get_node("Hole");
onready var Player: Node2D = get_node("Player");

func _ready():
	ran.randomize();
	
	# Idi od gori prema doli i od levo prema desno
	# i stvaraj i na jednomo naj stvoriti eto tak simple
	
	# i od 16 do 640 povecava se za 32
	# j od GM.GH + 16 do 360 povecava se za 32
	# GM.GH = 40, od 56 do 360
	
	var randomYHole = ran.randi_range(GameManager.GUIHeight + 64, 296);
	var randomYPlayer = ran.randi_range(GameManager.GUIHeight + 64, 296);
	
	Hole.position.y = randomYHole;
	Player.position.y = randomYPlayer;
	
	# We only generate walls but if we want to add ice and sand it's all here
	var pathWall = "res://Objects/Game/Wall.tscn";
	var pathIce = "res://Objects/Game/Ice.tscn";
	var pathSand = "res://Objects/Game/Sand.tscn";
	
	var wall = load(pathWall);
	var ice = load(pathIce);
	var sand = load(pathSand);
	
	var x = 0;
	var y = 0;
	
	for i in range (-4, 640, 64):
		var door = ran.randi_range(0, height - 1);
		for j in range (GameManager.GUIHeight + 16, 360, 32):
			if((y == door || (y-1) == door || (y+1) == door) && x != 0 && x != (width - 1)):
				y += 1;
				continue;
			var instance = wall.instance();
			wallSorter.add_child(instance);
			instance.set_position(Vector2(i, j).snapped(Vector2(16, 16)) + spawnOffset);
			y += 1;
		
		y = 0;
		x += 1;
