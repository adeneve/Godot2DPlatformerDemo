extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var animation_state_machine 
var delta_sum = 0
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	animation_state_machine.travel("Idle")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delta_sum += delta
	if delta_sum > 5:
		var random_number = rng.randf_range(0, 10.0)
		if random_number > 5:
			animation_state_machine.travel("Idle")
		else:
			animation_state_machine.travel("Shake")
		delta_sum = 0

