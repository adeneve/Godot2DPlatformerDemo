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
	status = $icePortalArea.connect("area_entered", self, "icePortal_handleCollide")
	assert(status == OK)
	status = $icePortalArea.connect("area_exited", self, "icePortal_handleCollideExit")
	assert(status == OK)
	pass # Replace with function body.

func handleCollide(body):
	Global.globalPlayerX = 950
	Global.globalPlayerY = -90
	Global.sceneToChangeTo = "res://World.tscn"
	add_child(transitionClose.instance())
	
func icePortal_handleCollide(body):
	if body.name == 'InteractionBox':
		$ColorRect.visible = true
		$ColorRect/Label.text = OS.get_scancode_string(InputMap.get_action_list("interact")[0].scancode)
		

func icePortal_handleCollideExit(body):
	if body.name == 'InteractionBox':
		$ColorRect.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InteractionManager_changeSceneIceLevel_signal():
	Global.sceneToChangeTo = "res://Levels/IceLevel.tscn"
	add_child(transitionClose.instance())
	pass # Replace with function body.



