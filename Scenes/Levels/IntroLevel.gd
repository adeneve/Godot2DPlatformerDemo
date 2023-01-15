extends Node2D


var transitionClose = preload("res://Scenes/TransitionClose.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const RATIO = 600.0 / 1024.0

var skeletonCreator
var respawning = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.position.x = Global.globalPlayerX
	$Player.position.y = Global.globalPlayerY
	$HUDLayer/HUD/Bars/Healthbar/HealthBar.value = 100
	$HUDLayer/HUD/Bars/Healthbar/HealthBar.visible = false
	$HUDLayer/HUD/Bars/Specialbar/Specialbar.visible = false
	$AnimationPlayer.play("ThanksForPlaying")
	pass # Replace with function body.


func _process(_delta):
	pass




func _on_BladeBoss_signal_bossBeat():
	$Label.visible = true
	pass # Replace with function body.
