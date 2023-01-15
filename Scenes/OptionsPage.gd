extends MarginContainer


var main_menu = "res://Scenes/MainMenu.tscn"
var keybindings = "res://Scenes/KeyBindings.tscn"

var transitionClose = preload("res://Scenes/TransitionClose.tscn")


onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selector
onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selector
onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Selector
onready var selector_four = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer4/HBoxContainer/Selector
onready var selector_five = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer5/HBoxContainer/Selector
onready var selector_six = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer6/HBoxContainer/Selector

onready var label_musicVolume = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/MusicVolume
onready var label_effectsVolume = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/EffectsVolume
onready var label_bindings = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Bindings
onready var label_fullScreen = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer4/HBoxContainer/FullScreen
onready var label_borderless = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer5/HBoxContainer/Borderless
onready var label_back = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer6/HBoxContainer/Back

onready var musicVolume_slider = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/MusicVolume/MusicVolumeSlider
onready var effectsVolume_slider = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/EffectsVolume/EffectsVolumeSlider

onready var fullscreen_chkbx = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer4/HBoxContainer/FullScreen/CheckBoxFullscreen
onready var borderless_chkbx = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer5/HBoxContainer/Borderless/CheckBoxBorderless

var current_selection = 0

func _ready():
	if OS.window_fullscreen:
		fullscreen_chkbx.pressed = true
	if OS.window_borderless:
		borderless_chkbx.pressed = true
	set_current_selection(0)

func _process(_delta):
	if OS.window_fullscreen:
		borderless_chkbx.disabled = true
	else:
		borderless_chkbx.disabled = false
	if Input.is_action_just_pressed("ui_down") and current_selection < 5:
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)
	elif Input.is_action_just_pressed("pause"):
		Global.sceneToChangeTo = main_menu
		add_child(transitionClose.instance())
	elif Input.is_action_pressed("ui_right"):
		if current_selection == 0:
			if musicVolume_slider.value < 2:
				musicVolume_slider.value += 1
		elif current_selection == 1:
			if effectsVolume_slider.value < 100:
				effectsVolume_slider.value += 10
	elif Input.is_action_pressed("ui_left"):
		if current_selection == 0:
			if musicVolume_slider.value > -40:
				musicVolume_slider.value -= 1
		elif current_selection == 1:
			if effectsVolume_slider.value > 0:
				effectsVolume_slider.value -= 10
		

func handle_selection(_current_selection):
	if _current_selection == 0:
		print("altering music volume")
	elif _current_selection == 1:
		print("altering sound effects volume")
	elif _current_selection == 2:
		Global.sceneToChangeTo = keybindings
		add_child(transitionClose.instance())
	elif _current_selection == 3:
		print("full screen")
		fullscreen_chkbx.pressed = !fullscreen_chkbx.pressed 
		OS.window_fullscreen = !OS.window_fullscreen
	elif _current_selection == 4:
		print("borderless")
		borderless_chkbx.pressed = !borderless_chkbx.pressed 
		OS.window_borderless = !OS.window_borderless
	elif _current_selection == 5:
		Global.sceneToChangeTo = main_menu
		add_child(transitionClose.instance())

func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	selector_four.text = ""
	selector_five.text = ""
	selector_six.text = ""
	
	label_bindings.get_node("RefRec").visible = false
	label_back.get_node("RefRec").visible = false
	
	
	if _current_selection == 0:
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
	elif _current_selection == 2:
		selector_three.text = ">"
		label_bindings.get_node("RefRec").visible = true
	elif _current_selection == 3:
		selector_four.text = ">"
	elif _current_selection == 4:
		selector_five.text = ">"
	elif _current_selection == 5:
		selector_six.text = ">"
		label_back.get_node("RefRec").visible = true


func _on_MusicVolumeSlider_value_changed(value):
	AudioController.setVolumne(value)
	pass # Replace with function body.



func _on_Bindings_mouse_entered():
	set_current_selection(2)



func _on_Bindings_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		Global.sceneToChangeTo = keybindings
		add_child(transitionClose.instance())


func _on_Back_mouse_entered():
	set_current_selection(5)


func _on_Back_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		Global.sceneToChangeTo = main_menu
		add_child(transitionClose.instance())



func _on_CheckBoxFullscreen_pressed():
	OS.window_fullscreen = fullscreen_chkbx.pressed 


func _on_CheckBoxBorderless_pressed():
	OS.window_borderless = borderless_chkbx.pressed 
