extends KinematicBody2D

var animation_state_machine 

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocityX = 0
var velocityY = 0
var accelY = 0
var timeAliveLimit = 10
var timeAlive = 0

# Called when the node enters the scene tree for the first time.
func ready(delta):
	animation_state_machine = $AnimationTree.get("parameters/playback")


func setVelocityX(val):
	velocityX = val
	
func setVelocityY(val):
	velocityY = val
	
func setAccelY(val):
	accelY = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocityY += accelY
	if animation_state_machine == null:
		animation_state_machine = $AnimationTree.get("parameters/playback")
	timeAlive += delta
	if timeAlive > timeAliveLimit:
		queue_free()
	position.x += velocityX * delta
	position.y += velocityY * delta
	if velocityX == 0:
		animation_state_machine.travel("Idle")
	else:
		animation_state_machine.travel("spin")
	
