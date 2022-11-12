extends Button
#foreach object in floors/walls -> group (ice/sand/wall), position(x,y), size(radius/extents)
	#hole -> position
	#player -> position
	#tree->root->level->editor->hole/player/sort

const saveDir = "user://CustomLevels/";
var path = saveDir + "my_level.json";
var firstSave = true;
var firstSavePrompt;
var textEdit;

func _ready():
	firstSavePrompt = get_parent().get_parent().get_node("CanvasLayer/Control") as Control;
	textEdit = firstSavePrompt.get_node("SaveNAME") as LineEdit;

func _on_Save_pressed():
	if(firstSave):
		firstSavePrompt.visible = true;
		firstSave = false;
		return;
	
	saveLevel();

func saveLevel() -> void:
	var root = get_tree().get_root().get_node("LevelEditor");
	var hole = root.get_node("Hole") as Sprite;
	var player = root.get_node("PseudoPlayer") as Sprite;
	var floors = root.get_node("Floor");
	var walls = root.get_node("Walls");
	
	var size;
	var position;
	var type;
	var rotation;
	var dict = {};
	
	var entities = Array();
	
	for entity in (floors.get_children() + walls.get_children()):
		rotation = 0;
		if(entity.is_in_group("ice")):
			type = "ice";
		if(entity.is_in_group("sand")):
			type = "sand";
		if(entity.is_in_group("wall")):
			type = "wall";
			rotation = rad2deg(entity.rotation); #round?
		
		size = entity.scale;
		position = entity.position;
		
		dict = {
			"Type": type,
			"Size": var2str(size),
			"Position": var2str(position),
			"Rotation": var2str(rotation)
		};
		
		entities.append(dict);
	
	var LevelData = {
		"HolePosition": var2str(hole.position),
		"PlayerPosition": var2str(player.position),
		"Entities": entities
	};
	
	var file = File.new();
	var error = file.open(path, File.WRITE);
	if (error == OK):
		file.store_line(to_json(LevelData));
		file.close();

func _on_SaveNAME_text_changed(_new_text):
	var orig_size = 200;
	var orig_margin = 220;
	
	# Keep textbox centered
	if(textEdit.rect_size.x > orig_size):
		textEdit.margin_left = orig_margin - ((textEdit.rect_size.x - orig_size) / 2);
	else:
		textEdit.margin_left = orig_margin;


func _on_SaveCANCEL_pressed():
	firstSavePrompt.visible = false;
	firstSave = true;

func _on_SaveOK_pressed():
	firstSavePrompt.visible = false;
	firstSave = false;
	
	path = saveDir + textEdit.text + ".json";
	
	saveLevel();
