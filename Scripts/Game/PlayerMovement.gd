extends KinematicBody2D

var startPos = Vector2();
var endPos = Vector2();
var dragging = false;

var maxDistance = 300;
var minDistance = 15;
var zeroDistance = 10;
var speed = 5;
var maxPuttSpeed = 300;
var normalFriction = 1.5;
var sandFriction = 10;
var iceFriction = 0.1;
var defrostEffectWeight = 0.2;
var enterHoleSpeed = 30;

var friction = float();
var defrosting = false;

var enterHole = false;

var velocity = Vector2();

export var linePath: NodePath;
export var holePath : NodePath;
onready var hole = get_node(holePath) as Area2D;
onready var line = get_node(linePath) as Line2D;

# Control variables when 2 sand/ice objects are next to eachother
# ex. when player is going from one sand to other sand
# he first enters the other sand (sandFriction)
# then exits the other sand -> normal friction
# this prevents that behaviour
var sandStack: int = 0;
var iceStack: int = 0;

func _ready():
	startPos = Vector2.ZERO;
	endPos = Vector2.ZERO;
	velocity = Vector2.ZERO;
	friction = normalFriction;
	line.visible = false;

func _process(_delta):
	dragging = Input.is_action_pressed("lclick");
	
	if Input.is_action_just_pressed("lclick"):
		startPos = get_global_mouse_position();
		line.set_point_position(0, startPos); 
		line.set_point_position(1, startPos);
	
	if Input.is_action_just_released("lclick"):
		if(startPos != Vector2(0, 0)):
			endPos = get_global_mouse_position();
			MovePlayer();
	
	if(dragging):
		if(startPos != Vector2(0, 0)):
			line.visible = true;
		line.set_point_position(1, get_global_mouse_position());
		endPos = get_global_mouse_position();
		var distance = startPos.distance_to(endPos);
		GameManager.Power = calculateMoveDistance(distance);
	else:
		line.visible = false;
	
	# Defrost after ice
	if(defrosting):
		friction = lerp(friction, normalFriction, defrostEffectWeight);
		if(friction >= normalFriction):
			defrosting = false;

func _physics_process(delta):
	var collision = move_and_collide(-velocity * delta); # move and check for collision
	velocity = velocity.linear_interpolate(Vector2(0, 0), friction * delta); # lerp velocity (friction)
	
	if(collision): 
		velocity = velocity.bounce(collision.normal);
	
	if(enterHole):
		if(position != hole.position):
			position = position.move_toward(hole.position, delta * enterHoleSpeed);
		else:
			enterHole = false;
			GameManager.FinishLevel(get_parent().name);

func _on_Hole_body_entered(_body):
	if(velocity.length() < maxPuttSpeed):
		velocity = Vector2.ZERO;
		enterHole = true;

func MovePlayer():
	if(enterHole):
		return; # if enter hole stuff happening dont move player
	var distance = startPos.distance_to(endPos);
	var direction = startPos.direction_to(endPos);
	if(distance == 0 && direction == Vector2.ZERO): 
		return; # if player clicked on screen, dir and dis is 0 so the player stops -> prevent this behaviour
	
	var moveDistance = calculateMoveDistance(distance); 
	
	if(moveDistance == 0):
		return;
	
	var moveX = moveDistance * direction.x;
	var moveY = moveDistance * direction.y;
	velocity += speed * Vector2(moveX, moveY);
	GameManager.Strokes += 1;

# if less than zeroDistance -> zero
# if between zeroDistance and minDistance -> minDistance
# if more than maxDistance -> maxDistance
func calculateMoveDistance(distance: float) -> float:
	var moveDis;
	if(distance < zeroDistance):
		moveDis = 0;
	elif(zeroDistance < distance && distance < minDistance):
		moveDis = minDistance;
	elif(distance > maxDistance):
		moveDis = maxDistance;
	else:
		moveDis = distance;
	
	return moveDis;

func _on_Sand_body_entered(body):
	if(body == self):
		sandStack += 1;
		defrosting = false;
		friction = sandFriction;
		# print("entered sand");


func _on_Sand_body_exited(body):
	if(body == self):
		sandStack -= 1;
		if(sandStack != 0):
			return;
		friction = normalFriction;
		# print("exited sand");


func _on_Ice_body_entered(body):
	if(body == self):
		iceStack += 1;
		friction = iceFriction;
		# print("entered ice");


func _on_Ice_body_exited(body):
	if(body == self):
		iceStack -= 1;
		if(iceStack != 0):
			return;
		defrosting = true;
		# print("exited ice");
