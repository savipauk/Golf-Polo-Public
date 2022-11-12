extends OptionButton

func _ready():
	add_item("8x8");
	add_item("16x16");

func _on_OptionButton_item_selected(index):
	if(index == 0):
		GameManager.gridSize = 8;
	else:
		GameManager.gridSize = 16;
	
