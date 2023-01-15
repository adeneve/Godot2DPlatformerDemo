extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = Color(0,0,0,0)
	$AnimationPlayer.play("CloseScene")

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene(Global.sceneToChangeTo)
	queue_free()


func _on_AnimationPlayer_animation_started(anim_name):
	layer = 1
