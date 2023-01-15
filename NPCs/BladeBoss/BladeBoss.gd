extends KinematicBody2D


signal player_pause_signal
signal player_start_signal

signal signal_bossHit
signal signal_bossBeat

var animation_state_machine 

const UP = Vector2(0, -1)
const GRAVITY = 10
const MAXFALLSPEED = 200
const MAXHORIZONTALSPEED = 60
const JUMPFORCE = 400
const HORIZONTALACCEL = 10

const SLOPE_THRESHOLD = deg2rad(70)
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_VALUE = 32


var velocity = Vector2()
var snap_vector = SNAP_DIRECTION * SNAP_VALUE

export var facing_right = true
var running = false

var decision = "idle"

var max_survey_distance = 1000
var cur_survey_distance = 0
var rng = RandomNumberGenerator.new()
# rng < 0.5 chase and attack , .5 - .8 throw, .8 - 1 super 

var timerSet = 0

var delta_acc = 0
var dialog_step = 0

var stopMoving = false

var intro_started = false
var leave = false

var dialog_over = false
var battleStartAnimOver = false
var dialog = ["I'm suprised you made it this far", "It's a shame it was all for nothing", 
"Prepare yourself!"
]

var battleState = -1  #0 = chase, #1 = throw, #2 = super
var battleStateDuration = -1
var battleStateTimer = 0
var readyForBattleStateChange = true

var bladeThrown = false
var bladeCaught = false

var gravityDisabled = false

var random_number = 0
var attacking = false

var startThrowAttack = false
var throwDelay = 1

var is_jumping = false

var shuriken
var multi_shot = false
const SHURIKEN_SPEED = 220
var singleShuriThrown = false

var startSuperAttack = false
var superJumpTimer = 1
var HYAH = false
var superResetOnCooldown = false

var hitCooldown = 0
var flicker = false
var flickerFreq = 0.1
var flickerTimer = flickerFreq
var flickerFlip = true

var health = 100
var defeated = false
var defeatedTimer = 3

export var doSpecial = false
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_state_machine = $AnimationTree.get("parameters/playback")
	animation_state_machine.travel("Idle")
	rng.randomize()
	var signalStatus = OK
	signalStatus = $Enemy_BossHbox.connect("area_entered", self, "handleHurt")
	assert(signalStatus == OK)
	shuriken = preload("res://EnvironmentArt/largeShuriken/largeShiruken.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if defeated:
		defeatedTimer -= delta
		if defeatedTimer < 0:
			queue_free()
		return
		
	if hitCooldown > 0:
		flicker = true
		hitCooldown -= delta
	else:
		flicker = false
		
	if flicker:
		if flickerTimer < 0:
			flickerFlip = !flickerFlip
			flickerTimer = flickerFreq
		else:
			flickerTimer -= delta
			
		if flickerFlip:
			$Sprite.material.set_shader_param("enableDeathShader", true)
		else:
			$Sprite.material.set_shader_param("enableDeathShader", false)
	else:
		$Sprite.material.set_shader_param("enableDeathShader", false)
		
	if facing_right:
		$Sprite.scale.x = 1
		$HitArea/CollisionShape2D.position.x = 27
	else:
		$HitArea/CollisionShape2D.position.x = -27
		$Sprite.scale.x = -1
	
	if dialog_over && !battleStartAnimOver:
		animation_state_machine.travel("battleReady")
		return
		
		
	if !is_on_floor():
		if !startSuperAttack:
			animation_state_machine.travel("jump")
	elif velocity.x != 0:
		is_jumping = false
		if !attacking:
			animation_state_machine.travel("Run")
	else:
		is_jumping = false
		animation_state_machine.travel("Idle")
		
	
	if dialog_over && battleStartAnimOver:
		# main processing
		var closeness = abs(position.x - Global.globalPlayerXForBoss)
		var chaseLeft = (position.x - Global.globalPlayerXForBoss > 0)
		
		if chaseLeft:
			facing_right = false
		else:
			facing_right = true
		
		if readyForBattleStateChange:
			random_number = rng.randf_range(0, 10.0)
			if random_number <= 5 or superResetOnCooldown:
				superResetOnCooldown = false
				battleState = 0
				battleStateDuration = 5
				battleStateTimer = 0
				readyForBattleStateChange = false
			elif random_number <= 8:
				battleState = 1
				readyForBattleStateChange = false
			elif !superResetOnCooldown:
				superResetOnCooldown = true
				battleState = 2
				battleStateDuration = 5
				battleStateTimer = 0
				readyForBattleStateChange = false
				
		match battleState:
			0: 
				print("chasing")
				battleStateTimer += delta
				if battleStateTimer > battleStateDuration:
					readyForBattleStateChange = true
					battleStateTimer = 0
					return
				else:
					if chaseLeft:
						velocity.x = - MAXHORIZONTALSPEED
					else:
						velocity.x = MAXHORIZONTALSPEED
						
					
					if closeness < 60:
						attacking = true
						var random_number_qa = rng.randf_range(0, 5.0)
						print(random_number_qa)
						var rngQAttack1 = (random_number_qa <= 1.5)
						var rngQAttack2 = (random_number_qa <= 3 && random_number_qa > 1.5)
						var rngQAttack3 = (random_number_qa <= 5 && random_number_qa > 3)
						if rngQAttack1:
							animation_state_machine.travel("qAttack1")
						if rngQAttack2:
							animation_state_machine.travel("qAttack2")
						if rngQAttack3:
							animation_state_machine.travel("qAttack3")
					else:
						attacking = false
			1:
				print("throwing")
				if !startThrowAttack:
					var random_number_jmp = rng.randf_range(0, 10.0)
					velocity.y = -JUMPFORCE
					velocity.x = -360
					if random_number_jmp > 5:
						velocity.x *= -1
					is_jumping = true
					startThrowAttack = true
				elif is_on_floor() && !is_jumping:
					velocity.x = 0
					if !bladeThrown:
						animation_state_machine.travel("throw")
						bladeThrown = true
					if !bladeCaught:
						if !singleShuriThrown:
							throwShuriken()
							singleShuriThrown = true
						animation_state_machine.travel("throwWait")
						throwDelay -= delta
						if throwDelay < 0:
							bladeCaught = true
							throwDelay = 3
						return
					if bladeCaught:
						readyForBattleStateChange = true
						startThrowAttack = false
						bladeCaught = false
						singleShuriThrown = false
						return
			2:
				print("super")
				velocity.x = 0
				gravityDisabled = true
				battleStateTimer += delta
				if battleStateTimer > battleStateDuration:
					readyForBattleStateChange = true
					battleStateTimer = 0
					gravityDisabled = false
					HYAH = false
					startSuperAttack = false
					return
				if !startSuperAttack:
					velocity.y = -JUMPFORCE / 5
					is_jumping = true
					superJumpTimer -= delta
					if superJumpTimer < 0:
						velocity.y = 0
						startSuperAttack = true
						superJumpTimer = 1
				else:
					velocity.y = 0
					if !HYAH:
						animation_state_machine.travel("superWait")
						HYAH = true
						
				
				
	if !gravityDisabled:
		velocity.y += GRAVITY
		if velocity.y > MAXFALLSPEED:
			velocity.y = MAXFALLSPEED
				

	
	if velocity.x > 0:
		facing_right = true
	if velocity.x < 0:
		facing_right = false
		
	snap_vector = SNAP_DIRECTION * 100 if !is_jumping else Vector2.ZERO
	var _v = move_and_slide_with_snap(velocity, snap_vector, UP, true)
				
		
	
	
func _on_Player_interact_signal():
	if !dialog_over && intro_started:
		if dialog_step < dialog.size():
			if $DialogFrame.speak(dialog[dialog_step]):
				dialog_step += 1
		else:
			if $DialogFrame.check():
				$DialogFrame.close()
				dialog_over = true
				emit_signal("player_start_signal")
				leave = true


func _on_Player_area2_signal():
	if !intro_started:
		intro_started = true
		stopMoving = true
		facing_right = false
		emit_signal("player_pause_signal")
		$DialogFrame.visible = true
		$DialogFrame/SpeakerName.text = "Razor"
		$DialogFrame.speak(dialog[0])
		dialog_step += 1
		$DialogFrame/SpeakerPicture.texture = load("res://NPCs/BladeBoss/normalBossP.png")


func _on_HUD_signal_bossReady():
	battleStartAnimOver = true
	

func handleHurt(body):
	if body.name == "attackHitBox" && hitCooldown <= 0:
		health -= 10
		emit_signal("signal_bossHit", -10)
		hitCooldown = 2
		if health == 0:
			defeated = true
			animation_state_machine.travel("death")
			emit_signal("signal_bossBeat")
	
func throwShuriken(special = false):
	print("spawn shuri")
	var new_node  = shuriken.instance()
	var new_node_up = null
	var new_node_down = null
	if !facing_right:
		new_node.setVelocityX(-SHURIKEN_SPEED)
		if special:
			new_node_up = shuriken.instance()
			new_node_up.setVelocityX(-SHURIKEN_SPEED/2)
			new_node_up.setVelocityY(SHURIKEN_SPEED/2)
			new_node_up.setAccelY(-2)
			new_node_down = shuriken.instance()
			new_node_down.setVelocityX(SHURIKEN_SPEED/2)
			new_node_down.setVelocityY(SHURIKEN_SPEED/2)
			new_node_down.setAccelY(-2)
	else:
		new_node.setVelocityX(SHURIKEN_SPEED)
		if special:
			new_node_up = shuriken.instance()
			new_node_up.setVelocityX(SHURIKEN_SPEED)
			new_node_up.setVelocityY(SHURIKEN_SPEED/1.5)
			new_node_up.setAccelY(-2)
			new_node_down = shuriken.instance()
			new_node_down.setVelocityX(-SHURIKEN_SPEED)
			new_node_down.setVelocityY(SHURIKEN_SPEED/1.5)
			new_node_down.setAccelY(-2)
	new_node.position.y = position.y
	new_node.position.x = position.x
	if special:
		new_node_up.position.y = position.y
		new_node_up.position.x = position.x
		new_node_down.position.y = position.y
		new_node_down.position.x = position.x
		get_parent().add_child(new_node_up)
		get_parent().add_child(new_node_down)
	else:
		get_parent().add_child(new_node)

