extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var originalString = ""
var current_char = 0
var chars = ""

const TEXTSPEED = 0.025

var ready = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpeakerWords.text = ""
	$CharTimer.wait_time = TEXTSPEED
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func check():
	return ready
	
func speak(words):
	if ready:
		ready = false
		originalString = words
		current_char = 0
		$CharTimer.start()
		return true
	else:
		return false

func close():
	if current_char >= originalString.length():
		visible = false
	
func _on_CharTimer_timeout():
	print("beep")
	print(str(current_char))
	print(originalString.length())
	if current_char <= originalString.length():
		chars = originalString.substr(0, current_char)
		current_char += 1
		$SpeakerWords.text = chars
	else:
		$CharTimer.stop()
		ready = true

