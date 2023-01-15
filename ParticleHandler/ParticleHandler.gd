extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	#free all particle nodes not emitting anythin

				
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for node in get_children():
		if node is Particles2D:
			if node.emitting == false:
				node.queue_free()


func _on_Player_spawn_particles( x, y, particleType = 0):
	if particleType == 0:
		var particles = Particles2D.new()
		particles.one_shot = true
		var pm  = ParticlesMaterial.new()
		pm.spread = 120
		pm.initial_velocity = 30
		pm.color = Color.orange
		particles.process_material = pm
		particles.lifetime = 3
		particles.amount = 10
		particles.explosiveness = 0.99
		particles.position.x = x
		particles.position.y = y
		particles.scale.x = 2.5
		particles.scale.y = 2.5
		particles.emitting = true
		add_child(particles)
	elif particleType == 1:
		var particles = Particles2D.new()
		particles.one_shot = true
		var pm  = ParticlesMaterial.new()
		pm.spread = 45
		pm.initial_velocity = 46
		pm.color = Color8(255,255,255,220)
		pm.direction.y = -.3
		pm.direction.x = 0
		pm.gravity.y = 69
		pm.damping = 47
		pm.flatness = 0.17
		pm.angular_velocity = 100
		particles.process_material = pm
		particles.lifetime = 0.6
		particles.amount = 15
		particles.explosiveness = 0.98
		particles.randomness = 0.72
		particles.position.x = x
		particles.position.y = y
		particles.scale.x = 1.6
		particles.scale.y = 1.6
		particles.emitting = true
		add_child(particles)
	pass # Replace with function body.
