extends LineEdit

var regex = RegEx.new();
var oldtext = "";

func _ready():
	text = "100";
	max_length = 4;
	regex.compile("^[0-9]*$");

func _process(_delta):
	if(getValue() > 1000):
		text = "1000";
	
	#if(getValue() == 0):
	#	text = "1";

func _on_Width_text_changed(new_text):
	if(regex.search(new_text)):
		oldtext = new_text;
	else:
		text = oldtext;
	set_cursor_position(text.length());


func _on_Height_text_changed(new_text):
	if(regex.search(new_text)):
		oldtext = new_text;
	else:
		text = oldtext;
	set_cursor_position(text.length());


func getValue():
	return(int(text));


