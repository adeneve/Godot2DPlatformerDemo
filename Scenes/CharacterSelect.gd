extends Control


const first_scene = "res://Scenes/Levels/IntroLevel.tscn"
const main_menu = "res://Scenes/MainMenu.tscn"

var transitionClose = preload("res://Scenes/TransitionClose.tscn")

var current_selection = 0

var validationResetTime = 5
var validationCurTime = 0

func _ready():
	$playerName.grab_focus()
	pass # Replace with function body.


func _process(_delta):
	
	validationCurTime += _delta
	if(validationCurTime > validationResetTime):
		$nameValidation.visible = false
		
	if Input.is_action_just_pressed("ui_right") and current_selection == 0:
		current_selection += 1
		$ReferenceRect.visible = false
		$ReferenceRect2.visible = true
	elif Input.is_action_just_pressed("ui_left") and current_selection == 1:
		current_selection -= 1
		$ReferenceRect.visible = true
		$ReferenceRect2.visible = false
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)
	elif Input.is_action_just_pressed("pause"):
		Global.sceneToChangeTo = main_menu
		add_child(transitionClose.instance())


func handle_selection(_current_selection):
	if len($playerName.text) == 0:
		$nameValidation.visible = true
		validationCurTime = 0
		return
	if current_selection == 0:
		Global.activeCharacterIndex = 0
	elif current_selection == 1:
		Global.activeCharacterIndex = 0 # second character not ready
		
	Global.activeSaveContext = SaveContext.new()
	Global.active_save_file = Global.save_file_path + "saveFile_" + str(Global.numSaveFiles) + ".res"
	Global.activeSaveContext.setlastPlayTime(OS.get_datetime())
	Global.saveData.push_front(Global.activeSaveContext)
	
	Global.activeSaveContext.setCharacter(Global.activeCharacterIndex)
	Global.activeSaveContext.setPlayerName($playerName.text)
	Global.sceneToChangeTo = first_scene
	add_child(transitionClose.instance())

func _on_TextureRect_mouse_entered():
	if(current_selection == 1):
		current_selection -= 1
		$ReferenceRect.visible = true
		$ReferenceRect2.visible = false


func _on_TextureRect2_mouse_entered():
	if(current_selection == 0):
		current_selection += 1
		$ReferenceRect.visible = false
		$ReferenceRect2.visible = true


func _on_TextureRect_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		handle_selection(current_selection)


func _on_TextureRect2_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		handle_selection(current_selection)
