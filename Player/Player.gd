extends KinematicBody2D

var animation_state_machine 

const mainMenu = "res://Scenes/MainMenu.tscn"

const UP = Vector2(0, -1)
var GRAVITY = 20
const MAXFALLSPEED = 200
var MAXHORIZONTALSPEED = 80
const JUMPFORCE = 400
var HORIZONTALACCEL = 10

var DASHSPEED = 220
var airDash = false
var isDashing = false
var dashCoolDown = 2
var dashTimer = 0
var dashEnabled = true


var transitionClose = preload("res://Scenes/TransitionClose.tscn")

var afterImage = preload("res://Player/PlayerDashFadingAfterImage.tscn")

const SLOPE_THRESHOLD = deg2rad(70)
var SNAP_DIRECTION = Vector2.DOWN
const SNAP_VALUE = 25

var rng = RandomNumberGenerator.new()

var velocity = Vector2()
var snap_vector = SNAP_DIRECTION * SNAP_VALUE

var facing_right = true
var running = false

var InteractionNPCName = "none"

var multiAttackChoice = "multiAttack_1"
var game_paused = 0
var player_paused = 0

signal dialog_signal
signal dialogExit_signal
signal interact_signal
signal response_up
signal response_down
signal reload_signal
signal spawn_particles
signal health_changed
signal show_hud

signal playerStart_signal

signal area1_signal
signal area2_signal


var triggerHurt = false

var health = 100
var dead = false
var hurt_direction = 0

var invincible = false
var invincivle_timer = 0

var is_jumping = false

var startDeathDelay = false
var deathDelayCounter = 0

var activeCharacterIndex = 1
onready var activeCharacterSprite = $Sprite

var attack_reach = 28
var attack_scale = 0.6

var enemiesInHitBox = []
var afterImageCooldown = 0.1
var afterImageTimer = 0
var afterImageEnabled = false

var input_disabled = true
var intro_over = false

var hud_visible = false

var transitioning = false

var jumpInitialized = false
var jumpPressedTimer = 0

var transitionRunDelay = 3
var transitionRunTimer = 0
var triggerTransition = false

var waitForBoss = false

var bossBattleStarted = false
var demoOver = false
var demoTimer = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = MAXHORIZONTALSPEED
	activeCharacterIndex = Global.activeCharacterIndex
	if activeCharacterIndex == 0:
		animation_state_machine = $AnimationTree.get("parameters/playback")
		$AnimationTreeF.active = false
		$AnimationTree.active = true
		$SpriteF.visible = false
		#attack_reach = 50
		attack_scale = 2.2
	if activeCharacterIndex == 1:
		animation_state_machine = $AnimationTreeF.get("parameters/playback")
		activeCharacterSprite = $SpriteF
		$AnimationTreeF.active = true
		$Sprite.visible = false
		HORIZONTALACCEL = 15
		MAXHORIZONTALSPEED = 100
		
	rng.randomize()
	var signalStatus = OK
	signalStatus = $attackHitBox.connect("area_entered", self, "handleCollide")
	assert(signalStatus == OK)
	signalStatus = $InteractionBox.connect("area_entered", self, "handleInteraction")
	assert(signalStatus == OK)
	signalStatus = $InteractionBox.connect("area_exited", self, "handleExitInteraction")
	assert(signalStatus == OK)
	signalStatus = $HitBox.connect("area_entered", self, "handleHurt")
	assert(signalStatus == OK)
	signalStatus = $HitBox.connect("area_exited", self, "handleLeaveHurt")
	assert(signalStatus == OK)
	setCameraLimits()
	if Global.pastIntro:
		intro_over = true
		input_disabled = false
	position.x = Global.globalPlayerX
	position.y = Global.globalPlayerY
	print(position.y)

func _physics_process(_delta):
	#$PerformanceDebug.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	#$PerformanceDebug.text += " MEM: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC/1024/1024))) + " MB"
	#var fps = Engine.get_frames_per_second()
	#print(fps)
	if bossBattleStarted:
		Global.globalPlayerXForBoss = position.x
		Global.globalPlayerYForBoss = position.y
	
	if demoOver:
		HandleDemoOver(_delta)
	
	if triggerTransition && (transitionRunTimer < transitionRunDelay):
		transitioning = true
		input_disabled = true
		transitionRunTimer += _delta
	elif transitionRunTimer > transitionRunDelay:
		transitionRunTimer = 0
		input_disabled = false
		transitioning = false
		triggerTransition = false
	
	if waitForBoss:
		input_disabled = true
	else:
		input_disabled = false
		
	if Input.is_action_pressed("jump") && jumpInitialized:
		jumpPressedTimer += _delta
		
	if Input.is_action_just_released("jump") && jumpInitialized:
		if jumpPressedTimer < 0.5:
			velocity.y /= 2
		jumpInitialized = false
		jumpPressedTimer = 0
		
	if !animation_state_machine.get_current_node() == "Dash" && $Sprite.material.get_shader_param("enableDashShader") == true:
		$Sprite.material.set_shader_param("enableDashShader", false)
		
	if !input_disabled:
		if !hud_visible:
			emit_signal("show_hud")
			hud_visible = true
	
	if transitioning:
		input_disabled = true
		animation_state_machine.travel("Running")
		velocity.x = MAXHORIZONTALSPEED/4
		
	if Input.is_action_just_pressed("pause") && !input_disabled:
		print("pause button pressed")
		_on_pause_button_pressed()
	if game_paused:
		return
		
	if !afterImageEnabled:
		afterImageTimer += _delta
		if afterImageTimer >= afterImageCooldown:
			afterImageTimer = 0
			afterImageEnabled = true
		
	if !dashEnabled:
		dashTimer += _delta
		if dashTimer >= dashCoolDown:
			dashTimer = 0
			dashEnabled = true
		
	if animation_state_machine.get_current_node() == "Dash" && afterImageEnabled:
		afterImageEnabled = false
		var instance = afterImage.instance()
		instance.position.x = position.x
		instance.position.y = position.y+15
		if !facing_right:
			instance.scale.x *= -1;
		get_parent().add_child(instance)
		
	if abs(position.y - $Camera2D.position.y) > 300:
		dead = true 
		
	if dead && startDeathDelay:
		if animation_state_machine.get_current_node() != "Death":
			animation_state_machine.travel("Death")
		deathDelayCounter += _delta
		velocity.y += GRAVITY
		if velocity.y > MAXFALLSPEED:
			velocity.y = MAXFALLSPEED
		velocity.x = 0
		velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true)
		if deathDelayCounter > 2:
			get_parent().add_child(transitionClose.instance())
			return
		return
			
	if dead && !startDeathDelay:
		set_collision_mask_bit(1, false)
		velocity.y += GRAVITY
		if velocity.y > MAXFALLSPEED:
			velocity.y = MAXFALLSPEED
		velocity.x = 0
		velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true)
		print("player dead")
		animation_state_machine.travel("Death")
		startDeathDelay = true
		return
		
	if invincible:
		invincivle_timer += _delta 
		activeCharacterSprite.modulate = Color(1, 1, 1, 0.8) # blue shade
		if invincivle_timer > 1.5:
			activeCharacterSprite.modulate = Color(1, 1, 1) # reset to default
			invincible = false
			invincivle_timer = 0
			
	if !invincible && len(enemiesInHitBox) > 0:
		handleHurt(enemiesInHitBox[0])
		
	if !("Attack" in animation_state_machine.get_current_node() ):
		$attackHitBox/attackCollider2D.disabled = true
		
	if animation_state_machine.get_current_node() == "Hurt" or animation_state_machine.get_current_node() == "HurtFlicker":
		if hurt_direction == 0:
			velocity.x = 30
		else:
			velocity.x = -30
		velocity.y = 100
		set_collision_mask_bit(1, false)
		velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true)
		return
	else:
		set_collision_mask_bit(1, true)
		
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
		print("firing signal")
		emit_signal("interact_signal")
	
		
	if player_paused:
		return
		
		
	if animation_state_machine.get_current_node() != "Hurt" and animation_state_machine.get_current_node() != "HurtFlicker" and triggerHurt:
		print("naniiii")
		if invincible:
			triggerHurt = false
			return
		invincible = true
		health -= 25
		emit_signal("health_changed", -25)
		if health > 0:
			animation_state_machine.travel("Hurt")
		else:
			dead = true
		triggerHurt = false
		return
		
	var normal = get_floor_normal()
	#print(normal)
	var stop_gravity = false
	if (normal.x < 0 && facing_right) || (normal.x > 0 && !facing_right):
		stop_gravity = true
		velocity.y = 0
		
	if !stop_gravity:
		velocity.y += GRAVITY
		if velocity.y > MAXFALLSPEED:
			velocity.y = MAXFALLSPEED
	
	snap_vector = SNAP_DIRECTION * SNAP_VALUE
	
	if facing_right:
		activeCharacterSprite.scale.x = 1
		$attackHitBox/attackCollider2D.scale.x = attack_scale
		$attackHitBox/attackCollider2D.position.x =  get_parent().position.x + attack_reach
	else:
		activeCharacterSprite.scale.x = -1
		#$Sprite/attackHitBox/attackCollider2D.position.x = -36
		$attackHitBox/attackCollider2D.scale.x = attack_scale
		$attackHitBox/attackCollider2D.position.x = get_parent().position.x - attack_reach
		
	if(animation_state_machine.get_current_node() != "Dash"):
		velocity.x = clamp(velocity.x, -MAXHORIZONTALSPEED, MAXHORIZONTALSPEED)
		GRAVITY = 20
		isDashing = false
	else:
		isDashing = true
		if airDash:
			velocity.y = 0
		else:
			GRAVITY = 10
	
	
	if Input.is_action_just_pressed("attack") && is_on_floor() && !isDashing && !input_disabled:
		animation_state_machine.travel("AttackStanding1")
		return
		
	if Input.is_action_just_pressed("attack") && !running && !is_on_floor() && !isDashing && !input_disabled:
		animation_state_machine.travel("JumpingAttack")
		return
		
	if Input.is_action_just_pressed("dash") && dashEnabled && !input_disabled:
		dashEnabled = false
		if !is_on_floor():
			airDash = true
		else:
			airDash = false
		animation_state_machine.travel("Dash");
		if facing_right:
			velocity.x = DASHSPEED
		else:
			velocity.x = -DASHSPEED
		#need dash cooldown as well
		return
		
		
	if Input.is_action_pressed("right") && !isDashing && !input_disabled:
		velocity.x += HORIZONTALACCEL
		if normal.x < 0:
			velocity.x += HORIZONTALACCEL * 3
		facing_right = true
		if Input.is_action_just_pressed("attack") && is_on_floor() && !input_disabled:
			animation_state_machine.travel("AttackStanding1") 
			return
		elif Input.is_action_just_pressed("attack") && !is_on_floor() && !input_disabled:
			animation_state_machine.travel("JumpingAttack")
			return
		else:
			animation_state_machine.travel("Running")
			running = true
	elif Input.is_action_pressed("left") && !isDashing && !input_disabled:
		velocity.x -= HORIZONTALACCEL
		if normal.x > 0:
			velocity.x -= HORIZONTALACCEL
		facing_right = false
		if Input.is_action_just_pressed("attack") && is_on_floor() :
			animation_state_machine.travel("AttackStanding1") 
		elif Input.is_action_just_pressed("attack") && !is_on_floor():
			animation_state_machine.travel("JumpingAttack")
			return
		else:
			animation_state_machine.travel("Running")
			running = true
	else:
		velocity.x = 0
		animation_state_machine.travel("Idle")
		running = false
		
	if isDashing:
		velocity.x = DASHSPEED
		if !facing_right:
			velocity.x = -DASHSPEED
	if get_floor_velocity().y < 0:
		position.y += get_floor_velocity().y * get_physics_process_delta_time() - GRAVITY * get_physics_process_delta_time() - 1

	if is_on_floor() or normal == Vector2.UP:
		is_jumping = false
		if Input.is_action_just_pressed("jump") && !input_disabled:
			print($Camera2D.limit_left)
			is_jumping = true
			jumpInitialized = true
			velocity.y = -JUMPFORCE
			emit_signal("spawn_particles", position.x, position.y + 32, 1)
	else:
		is_jumping = true
			
			
	if !intro_over:
		velocity.x = MAXHORIZONTALSPEED
		
	if transitioning:
		input_disabled = true
		velocity.x = MAXHORIZONTALSPEED/4
		
	if velocity.x != 0:
		animation_state_machine.travel("Running")
	
	SNAP_DIRECTION = Vector2.RIGHT if normal.x < 0 else Vector2.LEFT
	
	if normal == Vector2.UP:
		SNAP_DIRECTION = Vector2.DOWN

	snap_vector = SNAP_DIRECTION * 100 if !is_jumping else Vector2.ZERO
	
	
	if(is_jumping):
		if(velocity.y < 0):
			animation_state_machine.travel("Jumping")
		else:
			animation_state_machine.travel("Falling")

	velocity = move_and_slide_with_snap(velocity, snap_vector, UP, true, 4, 1.36)
	
			
func handleCollide(body):
	#print("wtf " + body.name)
	if body.name == 'DetectionBox':
		return
	if "Enemy" in body.name:
		emit_signal("spawn_particles", position.x + $attackHitBox/attackCollider2D.position.x, position.y + $attackHitBox/attackCollider2D.position.y)
		return


func handleHurt(body):
	if invincible && "Enemy" in body.name:
		enemiesInHitBox.push_front(body)
	if triggerHurt or invincible:
		return
	if animation_state_machine.get_current_node() == "HurtFlicker":
		return
	if "Platform_Area2D" == body.name:
		GRAVITY = 0
		velocity.y = body.get_parent().velocity_y
	if "Enemy" in body.name or body.name == "HenchmanHitBox" or body.name == "HitArea":
		triggerHurt = true
		if (abs(body.get_parent().position.x) - abs(position.x) > 0):
			if(body.get_parent().position.x > 0):
				position.x -= 10
				hurt_direction = 1
			else:
				position.x += 10
				hurt_direction = 0
		else:
			if(body.get_parent().position.x > 0):
				position.x += 10
				hurt_direction = 0
			else:
				position.x -= 10
				hurt_direction = 1

func handleLeaveHurt(body):
	if "Enemy" in body.name:
		enemiesInHitBox.erase(body)
			
	
func handleInteraction(body):
	#print(body.name)
	emit_signal("dialog_signal", body.name)
	if(body.name == "InteractionBox_BobT"):
		InteractionNPCName = body.name
		
func handleExitInteraction(body):
	emit_signal("dialogExit_signal", body.name)
	
	#also unpause player, and hide dialog box, just in case it locks up
func _on_pause_button_pressed():
	if game_paused:
		get_parent().get_node("pause_popup").hide()
		game_paused = 0
		get_tree().paused = false
		return
	get_tree().paused = true
	game_paused = 1
	get_parent().get_node("pause_popup").show()
	
func _on_pause_popup_close_pressed():
	get_parent().get_node("pause_popup").hide()
	get_tree().paused = false

	
func setCameraLimits():
	match Global.sceneToChangeTo:
		"res://Scenes/Levels/IntroLevel.tscn":
			$Camera2D.limit_left = -99999999
			$Camera2D.limit_right = 2300
			$Camera2D.limit_top = -110
			$Camera2D.limit_bottom = 130
			if Global.pastIntro:
				print("past intro")
				$Camera2D.limit_left = 2306
				$Camera2D.limit_right = 4946
				$Camera2D.offset.x = 0
				



func _on_BobTrufaunt_player_pause_signal():
	animation_state_machine.travel("Idle")
	player_paused = true
	pass # Replace with function body.


func _on_BobTrufaunt_player_start_signal():
	player_paused = false
	intro_over = true
	input_disabled = false
	$Camera2D.limit_left = -48
	pass # Replace with function body.


func _on_DashTipArea_area_entered(area):
	$TipBox/Label.text = "press " + OS.get_scancode_string(InputMap.get_action_list("dash")[0].scancode) + " to dash"
	$TipBox.visible = true
	pass # Replace with function body.


func _on_DashTipArea_area_exited(area):
	$TipBox.visible = false
	pass # Replace with function body.


func _on_JumpTipArea_area_entered(area):
	$TipBox/Label.text = "press " + OS.get_scancode_string(InputMap.get_action_list("jump")[0].scancode) + " to jump"
	$TipBox.visible = true
	pass # Replace with function body.


func _on_JumpTipArea_area_exited(area):
	$TipBox.visible = false


func _on_AttackTipArea_area_entered(area):
	$TipBox/Label.text = "press " + OS.get_scancode_string(InputMap.get_action_list("attack")[0].scancode) + " to attack"
	$TipBox.visible = true


func _on_AttackTipArea_area_exited(area):
	$TipBox.visible = false


func _on_LevelArea1_area_entered(area):
	if !transitioning:
		$CameraAnimation.play("CameraSlide")
		input_disabled = true
		transitioning = true
		triggerTransition = true

func _on_CameraAnimation_animation_finished(anim_name):
	$Camera2D.limit_left = $Camera2D.limit_right
	$Camera2D.offset.x = 0
	$Camera2D.limit_right = 10000
	#transitioning = false
	#input_disabled = false
	if position.x > 4944:
		$Camera2D.limit_right = 5355
	pass # Replace with function body.


func _on_Area1Start_area_entered(area):
	emit_signal("area1_signal")
	Global.globalPlayerX = position.x
	Global.globalPlayerY = position.y - 80
	Global.pastIntro = true


func _on_MoveTipArea_body_entered(body):
	if body.name == "Player":
		$TipBox/Label.text = "press " + OS.get_scancode_string(InputMap.get_action_list("left")[0].scancode) +  " and " + OS.get_scancode_string(InputMap.get_action_list("right")[0].scancode) + " to move"
		$TipBox.visible = true


func _on_MoveTipArea_body_exited(body):
	if body.name == "Player":
		$TipBox.visible = false



func _on_longJumpTipArea_body_entered(body):
	if body.name == "Player":
		$TipBox/Label.text = "press " + OS.get_scancode_string(InputMap.get_action_list("dash")[0].scancode) + " then " + OS.get_scancode_string(InputMap.get_action_list("jump")[0].scancode) + " quickly after to perform a long jump"
		$TipBox.visible = true
		$Camera2D.limit_right = 4946


func _on_longJumpTipArea_body_exited(body):
	if body.name == "Player":
		$TipBox.visible = false

func _on_Area2T_body_entered(body):
	if body.name == "Player":
		if !transitioning:
			$CameraAnimation.play("CameraSlide")
			input_disabled = true
			transitioning = true
			triggerTransition = true


func _on_Area2Start_body_entered(body):
	if !bossBattleStarted:
		bossBattleStarted = true
		Global.atBoss = true
		print("oni")
		waitForBoss = true
		Global.globalPlayerX = 4880
		Global.globalPlayerY = -80
		emit_signal("area2_signal")


func _on_HUD_signal_bossReady():
	print("chan")
	waitForBoss = false
	player_paused = false
	pass # Replace with function body.


func _on_BladeBoss_player_pause_signal():
	animation_state_machine.travel("Idle")
	player_paused = true
	transitionRunTimer = 100
	pass # Replace with function body.



func _on_BladeBoss_signal_bossBeat():
	input_disabled = true
	demoOver = true
	pass # Replace with function body.

func HandleDemoOver(delta):
	demoTimer -= delta
	if demoTimer < 0:
		Global.sceneToChangeTo = mainMenu
		get_parent().add_child(transitionClose.instance())
