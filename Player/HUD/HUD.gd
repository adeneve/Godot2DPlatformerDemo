extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal signal_bossReady

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_health_changed(healthChange):
	$Bars/Healthbar/HealthBar.value += healthChange
	pass # Replace with function body.


func _on_Player_show_hud():
	$Bars/Healthbar/HealthBar.visible = true
	$Bars/Specialbar/Specialbar.visible = false
	pass # Replace with function body.



func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("signal_bossReady")
	pass # Replace with function body.


func _on_BladeBoss_player_start_signal():
	$BossBars.visible = true
	$AnimationPlayer.play("loadBossBar")


func _on_BladeBoss_signal_bossHit(change):
	$BossBars/Healthbar/Healthbar.value += change
	pass # Replace with function body.
