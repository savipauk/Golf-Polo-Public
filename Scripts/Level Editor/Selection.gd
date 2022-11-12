extends Area2D

signal selection_toggled(selection);

var selected = false setget set_selected;

var selectable = true;

var selector; # item select sprite
var levelEditor: Node2D; # leveleditor node
var parent : Node2D; # parent node (wall/sand/ice)
var sorter: Node; # sorter node for ice/sand
var wallSorter: Node; # sorter node for wall
var scales: Control; # scale node for resizing item
var collisionShape: CollisionShape2D; # collisionshape node

var spawnOffset = Vector2(0, -8); # how much to move next item on create

var dragging = false; # variable that tracks if the player is dragging the item
var mouseDragDiff = Vector2(0, 0); # difference between mouse position and item position for smooth snapping
var dragOffset = Vector2(0, GameManager.GUIHeight); # gui offset for grid
var dragMaxXOffset = 0; # scaling offset
var dragMaxYOffset = 0; # scaling offset


var dragMaxX;
var dragMaxY;

# Global variable used for calculations in functions
# Refers to object position or other object position
# Updates when dragging or spawning a new object
var pos = Vector2(0, 0);


var xscale: float = 100;
var yscale: float = 100;

func _ready():
	levelEditor = get_tree().get_root().get_node("LevelEditor");
	sorter = levelEditor.get_node("Floor");
	wallSorter = levelEditor.get_node("Walls");
	parent = get_parent();
	selector = parent.get_node("Selector");
	scales = levelEditor.get_node("BackgroundGUI").get_node("Control").get_node("Scale");
	collisionShape = get_node("CollisionShape2D") as CollisionShape2D;
	
	getDragMaxOffset();

func _process(_delta):
	# Can't move an item if something is above it
	if(get_overlapping_areas().empty()):
		selectable = true;
	else:
		for entity in get_overlapping_areas():
			# ... -> leveleditor -> hole(my parent) ... pseudoplayer(you)
			# MY PARENT INDEX > YOUR PARENT INDEX
			
			# Get which item is higher
			var myIndex = parent.get_index();
			var yourIndex = entity.get_parent().get_index();
			if(parent.is_in_group("editoritem")):
				if(parent.is_in_group("wall")):
					myIndex = wallSorter.get_index();
				else:
					myIndex = sorter.get_index();
			
			if(entity.get_parent().is_in_group("editoritem")):
				if(entity.get_parent().is_in_group("wall")):
					yourIndex = wallSorter.get_index();
				else:
					yourIndex = sorter.get_index();
			
			if(myIndex < yourIndex):
				selectable = false;
	
	# If I am not selected, below isn't for me
	if(!selected):
		return;
	
	# Item scaling
	xscale = scales.get_node("Width").getValue();
	yscale = scales.get_node("Height").getValue();
	xscale /= 100;
	yscale /= 100;
	xscale = clamp(xscale, 0.5, 10);
	yscale = clamp(yscale, 0.5, 10);
	
	if(parent.is_in_group("editoritem")):
		var sc = Vector2(xscale, yscale);
		var oldscale = parent.scale;
		var taken;
		parent.scale = sc;
		# If I want to prevent scaling into Walls
#		if(parent.is_in_group("editoritem")):
#			taken = isMyNewSpotTaken(sorter.get_children() + wallSorter.get_children());
		# If I don't care about scaling into Walls
		if(parent.is_in_group("wall")):
			taken = isMyNewSpotTaken(wallSorter.get_children());
		elif(parent.is_in_group("carpet")):
			taken = isMyNewSpotTaken(sorter.get_children());
		
		if(taken):
			parent.scale = oldscale;
		
		# Recalculate drag variables
		getDragMaxOffset();
	
	dragging = Input.is_action_pressed("lclick");
	
	if(dragging):
		dragMaxX = get_viewport().size.x - dragMaxXOffset;
		dragMaxY = get_viewport().size.y - dragMaxYOffset;
		# mouse_pos + mouseDragDiff to avoid snapping movement on start of drag
		pos = Vector2(get_global_mouse_position() + mouseDragDiff).snapped(Vector2(GameManager.gridSize, GameManager.gridSize)) + dragOffset;
		# Clamp position to room size
		pos.x = clamp(pos.x, dragMaxXOffset, dragMaxX);
		pos.y = clamp(pos.y, GameManager.GUIHeight + dragMaxYOffset, dragMaxY);
		
		var taken := false;
		if(parent.is_in_group("editoritem")):
			if(parent.is_in_group("wall")):
				taken = isMyNewSpotTaken(wallSorter.get_children());
			elif(parent.is_in_group("carpet")):
				taken = isMyNewSpotTaken(sorter.get_children());
		if(!taken):
			parent.global_position = pos;

func isMyNewSpotTaken(_sorterItems) -> bool:
	var taken := false;
	
	for entity in _sorterItems:
		if(entity == parent):
			continue;
		
		# if they are rotated differently then it doesn't matter if they are overalapping (for walls)
		if(entity.rotation != parent.rotation):
			continue;
		
		# check if (my pos + extents) overlaps (pos + extents of any other object)
		
		# We need to recalculate myExtents because of wall rotations
		var myExtents = collisionShape.shape.extents;
		myExtents *= parent.scale;
		
		var entityExtents = entity.get_node("Selection").get_node("CollisionShape2D").shape.extents;
		entityExtents *= entity.scale;
		if(round(rad2deg(entity.rotation)) == 90):
			var c = entityExtents.x;
			entityExtents.x = entityExtents.y;
			entityExtents.y = c;

			c = myExtents.x;
			myExtents.x = myExtents.y;
			myExtents.y = c;
		
		var entityPos = entity.global_position;
		
		if(pos.x - myExtents.x < entityPos.x + entityExtents.x && pos.x + myExtents.x > entityPos.x - entityExtents.x):
			if(pos.y - myExtents.y < entityPos.y + entityExtents.y && pos.y + myExtents.y > entityPos.y - entityExtents.y):
				taken = true;
				# print("my extents: ", myExtents, "\nentity extents: ", entityExtents);
				break;
	
	return taken;

func set_selected(selection):
	if(selection):
		# only one can be selected
		_make_exclusive();
		add_to_group("selected");
		# Put self on top, except pseudoplayer
	#	if(parent.get_parent() == sorter):
	#		sorter.move_child(parent, sorter.get_child_count() - 1);
	else:
		if(is_in_group("selected")):
			 remove_from_group("selected");
	
	selected = selection;
	
	# signal that makes selector visible
	emit_signal("selection_toggled", selected);

func _make_exclusive():
	get_tree().call_group("selected", "set_selected", false);

func _input(event):
	if(selected):
		if(event is InputEventMouseButton && event.is_action_pressed("lclick")):
			set_selected(false);
		if(event is InputEventKey && event.is_action_pressed("rotatewallkey")):
			if(parent.is_in_group("wall")):
				var oldRotation = parent.rotation;
				if(parent.rotation == 0):
					parent.rotate(0.5 * PI);
				else:
					parent.rotate(-0.5 * PI);
				
				var taken := isMyNewSpotTaken(wallSorter.get_children());
				
				if(taken):
					parent.rotation = oldRotation;

# _input is defined by Node -> generic input and it goes first 
# _input_event is defined by Area2D -> physics object and it goes later
# and it knows it's happening on it

func _input_event(_viewport, event, _shape_idx):
	if(!selected && selectable):
		if(event is InputEventMouseButton && event.is_action_pressed("lclick")):
			mouseDragDiff = parent.global_position - get_global_mouse_position() - dragOffset;
			# print(parent.name);
			set_selected(true);
	
	if(event is InputEventMouseButton && event.is_action_pressed("rclick")):
		if(parent.is_in_group("editoritem")):
			parent.queue_free();
	
	if(event is InputEventMouseButton && event.is_action_pressed("mclick")):
		if(parent.is_in_group("ice")):
			LoadInstance("res://Objects/LevelEditor/IceLevelEditor.tscn", false);
		elif(parent.is_in_group("sand")):
			LoadInstance("res://Objects/LevelEditor/SandLevelEditor.tscn", false);
		elif(parent.is_in_group("wall")):
			LoadInstance("res://Objects/LevelEditor/WallLevelEditor.tscn", true);


func _on_Selection_selection_toggled(selection):
	selector.visible = selection;

# Calculates offset when dragging to prevent being able to put item outside room etc.
func getDragMaxOffset() -> void:
	if(get_child_count() == 0):
		return;
	
	if(parent.is_in_group("editoritem")):
		dragMaxXOffset = collisionShape.shape.extents.x * parent.scale.x;
		dragMaxYOffset = collisionShape.shape.extents.y * parent.scale.y;
		if(parent.is_in_group("wall")):
			# switch x and y if wall is rotated because extents stay the same
			if(parent.rotation_degrees == 90):
				var change = dragMaxXOffset;
				dragMaxXOffset = dragMaxYOffset;
				dragMaxYOffset = change;
	else:
		dragMaxXOffset = collisionShape.shape.radius;
		dragMaxYOffset = dragMaxXOffset;

# Taken from LevelEditorButtons.gd
# do something about this
func LoadInstance(path, isWall) -> void:
	var scene = load(path);
	var instance = scene.instance();
	
	var entityExtents;
	var entityPos;
	var myExtents;
	
	if(isWall):
		wallSorter.add_child(instance);
		instance.rotation = parent.rotation;
		myExtents = Vector2(4, 16);
	else:
		sorter.add_child(instance);
		myExtents = Vector2(16, 16);
	
	var foundPos := false;
	pos = Vector2(0, 0);
	var taken;
	
	# check where it can spawn
	for i in range (16, 640, 32):
		for j in range (GameManager.GUIHeight + 16, 360, 32):
			pos = Vector2(i, j);
			taken = false;
			
			# Similar code to isMyNewSpotTaken(), but no parent and rotation checks
			for entity in (sorter.get_children() + wallSorter.get_children()):
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
