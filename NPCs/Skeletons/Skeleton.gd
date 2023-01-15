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
var dying = 0

var max_survey_distance = 100
var cur_survey_distance = 0
var rng = RandomNumberGenerator.new()

var timerSet = 0

var delta_acc = 0

# Called when the node enters the scene tree for the first time.

func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	animation_state_machine.travel("skeleton_spawnEntry")
	$Sprite.show()
	rng.randomize()
	var status = OK
	status = $Enemy_SkeletonHitBox.connect("area_entered", self, "handleCollide")
	assert(status == OK)


func _physics_process(delta):
	
	if dying:
		$CollisionShape2D.disabled = true
		$Enemy_SkeletonHitBox/CollisionShape2D2.disabled = true
		animation_state_machine.travel("skeleton_death")
		if animation_state_machine.get_current_node() == "skeleton_dead":
			self.queue_free()
		return
		
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
	
	if random_number < 2 && delta_acc > 3:
		delta_acc = 0
		decision = "idle"

	if random_number >= 2 && delta_acc > 3:
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
		
		
	if velocity.x != 0 && !dying:
		animation_state_machine.travel("skeleton_run") 
	else:
		animation_state_machine.travel("skeleton_idle") 
	
	#move_and_slide(velocity, UP, true)
	var _v = move_and_slide_with_snap(velocity, snap_vector, UP, true)
	
	
func handleCollide(body):
	print(body.name)
	if body.name == "attackHitBox":
		dying = 1
	
