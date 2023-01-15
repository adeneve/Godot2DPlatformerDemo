extends KinematicBody2D

var animation_state_machine 

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAXFALLSPEED = 200
const MAXHORIZONTALSPEED = 80
const JUMPFORCE = 400
const HORIZONTALACCEL = 10

const SLOPE_THRESHOLD = deg2rad(70)
var SNAP_DIRECTION = Vector2.DOWN
const SNAP_VALUE = 32

var rng = RandomNumberGenerator.new()

var velocity = Vector2()
var snap_vector = SNAP_DIRECTION * SNAP_VALUE

var facing_right = true
var running = false

var game_paused = 0
var player_paused = 0

var decision = "idle"

signal reload_signal

signal playerStart_signal

var triggerHurt = false

var health = 2
var dead = false

var max_survey_distance = 100
var cur_survey_distance = 0

var timerSet = 0

var delta_acc = 0
var dying = 0

var attacking = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	rng.randomize()
	$Sprite.show()
	var signalStatus = OK
	signalStatus = $DetectionBox.connect("body_entered", self, "handleDetection")
	assert(signalStatus == OK)
	signalStatus = $Enemy_HenchmanHitBox.connect("area_entered", self, "handleHurtHench")
	assert(signalStatus == OK)
	signalStatus = $PrepHitArea.connect("area_entered", self, "prepLaunchAttack")
	assert(signalStatus == OK)

func _physics_process(delta):
		
	if dead:
		$CollisionShape2D.disabled = true
		$Enemy_HenchmanHitBox/CollisionShape2D.disabled = true
		velocity.x = 0
		velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true)
		animation_state_machine.travel("Death")
		if animation_state_machine.get_current_node() == "DeathEnd":
			self.queue_free()
		return
		
	
	if attacking:
		animation_state_machine.travel("Attack")
		attacking = 0
		return

		
	if animation_state_machine.get_current_node() == "Hurt":
		velocity.x = 0
		velocity.y = 100
		velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true)
		return
		
	
	if animation_state_machine.get_current_node() != "Hurt" and triggerHurt:
		health -= 1
		if health > 0:
			animation_state_machine.travel("Hurt")
		else:
			dead = true
		triggerHurt = false
		return
		
	var normal = get_floor_normal()

	var stop_gravity = false
	if (normal.x < 0 && facing_right) || (normal.x > 0 && !facing_right):
		stop_gravity = true
		velocity.y = 0
		
	if !stop_gravity:
		velocity.y += GRAVITY
		if velocity.y > MAXFALLSPEED:
			velocity.y = MAXFALLSPEED
	
	snap_vector = SNAP_DIRECTION * SNAP_VALUE
		
	match decision:
		"idle": velocity.x = 0
		"left": velocity.x = -50
		"right": velocity.x = 50
		
	delta_acc += delta
	
	if facing_right:
		$Sprite.scale.x = 1
		$HitArea/CollisionShape2D.position.x = 24
		$PrepHitArea/CollisionShape2D.position.x = 24
	else:
		$Sprite.scale.x = -1
		$HitArea/CollisionShape2D.position.x = -24
		$PrepHitArea/CollisionShape2D.position.x = -24
		
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
		animation_state_machine.travel("Run") 
	else:
		animation_state_machine.travel("Idle") 
		
	velocity.x = clamp(velocity.x, -MAXHORIZONTALSPEED, MAXHORIZONTALSPEED)
	
	
	
	SNAP_DIRECTION = Vector2.RIGHT if normal.x < 0 else Vector2.LEFT

	snap_vector = SNAP_DIRECTION * 128000

	velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true, 4, 1.36)
		
		
func slope(slides: int):
	for i in slides:
		var touched = get_slide_collision(i)
		if is_on_floor() && touched.normal.y < 1.0 && velocity.x != 0.0 && touched.normal.y != UP.y:
			velocity.y = - (GRAVITY + 30)
			
	# is to just transition to a still attack animation for 75ms

func handleHurtHench(body):
	if animation_state_machine.get_current_node() == "Hurt":
		return
	if body.name == "attackHitBox":
		triggerHurt = true

func handleDetection(body):
	if(body.name == "Player"):
		delta_acc = 0
		decision = "left"
		if position.x - body.position.x < 0:
			decision = "right"
	return
	
		
	
	
func prepLaunchAttack(body):
	if(body.name == "InteractionBox"):
		attacking = 1

	
	#also unpause player, and hide dialog box, just in case it locks up
