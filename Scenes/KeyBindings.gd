extends CanvasLayer


onready var buttonScript = load("res://KeyButton.gd")
var options_page = "res://Scenes/OptionsPage.tscn"

var transitionClose = preload("res://Scenes/TransitionClose.tscn")

var keybinds

onready var btn_container = $Panel/VBoxContainer

onready var btn_save = $Panel/save
onready var btn_back = $Panel/back

onready var lbl_inuse = $Panel/inUseErr

onready var dynamic_font

# Called when the node enters the scene tree for the first time.
func _ready():
	keybinds = Global.keybinds.duplicate()
	
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/Onett.ttf")
	dynamic_font.size = 16
	dynamic_font.outline_color = Color("#ffffff")
	dynamic_font.use_filter = true
	
	for key in keybinds.keys():
		var hbox = HBoxContainer.new()
		var lbl = Label.new()
		var btn = Button.new()
		
		lbl.add_font_override("font", dynamic_font)
		btn.add_font_override("font", dynamic_font)
		
		hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		lbl.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		btn.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		lbl.text = key
		btn.text = OS.get_scancode_string(keybinds[key])
		
		btn.set_script(buttonScript)
		btn.key = key
		btn.value = keybinds[key]
		btn.menu = self
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		
		hbox.add_child(lbl)
		hbox.add_child(btn)
		btn_container.add_child(hbox)
	

func change_bind(key, value):
	var inuse = false
	for keyB in keybinds.keys():
		if keybinds[keyB] == value:
			inuse = true
			lbl_inuse.add_color_override("font_color", Color(255, 0, 0))
			lbl_inuse.percent_visible = 1
			lbl_inuse.text = "Key " + OS.get_scancode_string(value) + " Already Used For " + keyB
	if !inuse:
		lbl_inuse.percent_visible = 0
		keybinds[key] = value
	return inuse
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_back_pressed():
	Global.sceneToChangeTo = options_page
	get_tree().change_scene(Global.sceneToChangeTo)
	pass # Replace with function body.


func _on_save_pressed():
	Global.keybinds = keybinds.duplicate()
	Global.set_key_binds()
	Global.write_config()
	lbl_inuse.text = "Saved Successfully."
	lbl_inuse.add_color_override("font_color", Color(0, 255, 0))
	lbl_inuse.percent_visible = 1
	pass # Replace with function body.
