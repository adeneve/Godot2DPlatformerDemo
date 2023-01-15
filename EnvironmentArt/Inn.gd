extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var animation_state_machine
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	animation_state_machine.travel("idle")
	var status = OK
	status = $doorArea.connect("area_entered", self, "handleCollide")
	assert(status == OK)
	status = $doorArea.connect("area_exited", self, "handleCollideExit")
	assert(status == OK)


func handleCollide(body):
	if body.name == 'InteractionBox':
		animation_state_machine.travel("doorOpen") 
		$ColorRect.visible = true
		$ColorRect/Label.text = OS.get_scancode_string(InputMap.get_action_list("interact")[0].scancode)
		

func handleCollideExit(body):
	if body.name == 'InteractionBox':
		animation_state_machine.travel("idle") 
		$ColorRect.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
