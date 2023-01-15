extends Node2D

var transitionClose = preload("res://UI/TransitionClose.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var status = OK
	status = $doorExit.connect("area_entered", self, "handleCollide")
	assert(status == OK)

	pass # Replace with function body.

func handleCollide(body):
	Global.globalPlayerX = 280
	Global.globalPlayerY = -30
	Global.sceneToChangeTo = "res://World.tscn"
	add_child(transitionClose.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
