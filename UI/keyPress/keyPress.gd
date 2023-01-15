extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.visible = true
	$ColorRect/Label.text = OS.get_scancode_string(InputMap.get_action_list("interact")[0].scancode)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
