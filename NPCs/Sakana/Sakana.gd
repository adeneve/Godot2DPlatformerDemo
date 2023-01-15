extends KinematicBody2D


var animation_state_machine 

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAXFALLSPEED = 200
const MAXHORIZONTALSPEED = 80
const JUMPFORCE = 300
const HORIZONTALACCEL = 10

const SLOPE_THRESHOLD = deg2rad(70)
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_VALUE = 32


var velocity = Vector2()
var snap_vector = SNAP_DIRECTION * SNAP_VALUE

var facing_right = true
var running = false

var decision = "idle"

var max_survey_distance = 50
var cur_survey_distance = 0
var rng = RandomNumberGenerator.new()

var timerSet = 0

var delta_acc = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	animation_state_machine.travel("Idle")
	$Sprite.show()
	rng.randomize()
	var status = OK
	status = $InteractionBox_Sak.connect("area_entered", self, "handleCollide")
	assert(status == OK)
	status = $InteractionBox_Sak.connect("area_exited", self, "handleCollideExit")
	assert(status == OK)

func _physics_process(delta):
		
	velocity.y += GRAVITY
	if velocity.y > MAXFALLSPEED:
		velocity.y = MAXFALLSPEED
		

	match decision:
		"idle": velocity.x = 0
		"left": velocity.x = -18
		"right": velocity.x = 18
		
	delta_acc += delta
	
	if facing_right:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
		
	velocity.x = clamp(velocity.x, -MAXHORIZONTALSPEED, MAXHORIZONTALSPEED)
	
	
	cur_survey_distance += velocity.x * delta

	#need logic for random movement
	var random_number = rng.randf_range(0, 10.0)
	
	if random_number < 5 && delta_acc > 3:
		delta_acc = 0
		decision = "idle"

	if random_number >= 5 && delta_acc > 3:
		#decide to run left or right
		delta_acc = 0
		random_number = rng.randf_range(0, 10.0)
		if random_number < 5 && -(cur_survey_distance) < (max_survey_distance):
			decision = "left"
		elif cur_survey_distance < max_survey_distance:
			decision = "right"
			
	if cur_survey_distance > max_survey_distance:
		cur_survey_distance = max_survey_distance
		velocity.x = 0
	if -(cur_survey_distance) > (max_survey_distance):
		cur_survey_distance = -max_survey_distance
		velocity.x = 0
		
	
	if velocity.x > 0:
		facing_right = true
	if velocity.x < 0:
		facing_right = false
		
		
	if velocity.x != 0:
		animation_state_machine.travel("Run") 
	else:
		animation_state_machine.travel("Idle") 
	
	#move_and_slide(velocity, UP, true)
	var _v = move_and_slide_with_snap(velocity, snap_vector, UP, true)
	
	
func handleCollide(body):
	print("sakana collide with" + body.name)
	if(body.name == "InteractionBox"):
		$ColorRect.visible = true
		$ColorRect/Label.text = OS.get_scancode_string(InputMap.get_action_list("interact")[0].scancode)
		
func handleCollideExit(body):
	print("sakana collide exit with" + body.name)
	if(body.name == "InteractionBox"):
		$ColorRect.visible = false
