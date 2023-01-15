extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var filepath = "res://LocalData/keybindings.tres"

var inputMapPathUser = "user://ElementalBlade_keybindings.tres"

var save_file_path = "user://"
var active_save_file = save_file_path + "saveFile_01.res"

var numSaveFiles = 0

var configFile
var sceneToChangeTo = preload("res://Scenes/LogoScene.tscn")

var globalPlayerX = 0
var globalPlayerY = 0

var globalPlayerXForBoss = 0
var globalPlayerYForBoss = 0

var pastIntro = false
var atBoss = false


var keybinds = {}

var saveData = []

var activeSaveContext : SaveContext

var activeCharacterIndex = 1

var has_saveFile = false

# Called when the node enters the scene tree for the first time.
func _ready():
	configFile = ConfigFile.new() 
	if configFile.load(inputMapPathUser) != OK:
		if configFile.load(filepath) != OK:
			print("CONFIG FILE NOT FOUND")
			get_tree().quit()
		
	for key in configFile.get_section_keys("keybinds"):
		var key_value = configFile.get_value("keybinds",key)
		print(key)
		print(key_value)
		print(OS.get_scancode_string(key_value))
		
		keybinds[key] = key_value


		
	set_key_binds()
	
	load_save_file()
		
func set_key_binds():
	for key in keybinds.keys():
		var val = keybinds[key]
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key, actionlist[0])
		
		var new_key = InputEventKey.new()
		new_key.set_scancode(val)
		InputMap.action_add_event(key, new_key)
			
func write_config():
	for key in keybinds.keys():
		var value = keybinds[key]
		configFile.set_value("keybinds", key, value)
	configFile.save(filepath)
	configFile.save(inputMapPathUser)
	
	
func load_save_file():
	var files = []
	var dir = Directory.new()
	if(!dir.dir_exists(save_file_path)):
		dir.make_dir(save_file_path)
	dir.open(save_file_path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.begins_with("saveFile"):
			var saveFile = ResourceLoader.load(save_file_path + file)
			if saveFile is SaveContext:
				saveData.push_front(saveFile)
				numSaveFiles += 1
				
	dir.list_dir_end()

func write_save_file():
	activeSaveContext.lastPlayTime = OS.get_date()
	var result = ResourceSaver.save(active_save_file, activeSaveContext)
	print(active_save_file)
	print("result " + str(result))
	assert(result == OK)

		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
