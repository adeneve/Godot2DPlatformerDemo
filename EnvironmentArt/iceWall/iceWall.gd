extends KinematicBody2D

var animation_state_machine 

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var gravity = 10
var originalVelocity = 0
var velocityX = 0
var collisions = 0
var collisionLimit = 2
var timeAlive = 0
var timeLimit = 40
var dead = false

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	var signalStatus = OK
	signalStatus = $Enemy_iceWallHitBox.connect("area_entered", self, "handleHurtWall")
	assert(signalStatus == OK)


func setVelocityX(val):
	originalVelocity = val
	velocity.x = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeAlive += delta
	if animation_state_machine == null:
		animation_state_machine = $AnimationTree.get("parameters/playback")
		
	if animation_state_machine.get_current_node() == "DestroyEnd":
		dead = true
		
	if timeAlive > timeLimit or dead:
		queue_free()
		
	velocity.y += gravity
	
	if collisions > collisionLimit:
		animation_state_machine.travel("Destroy")
	else:
		animation_state_machine.travel("Idle")
		
	velocity = move_and_slide(velocity, Vector2.UP, false)
	
	if abs(velocity.x) < 1:
		collisions += 1
		originalVelocity *= -1
		velocity.x = originalVelocity
	

func handleHurtWall(body):
	if body.name == "attackHitBox":
		collisions += 3
