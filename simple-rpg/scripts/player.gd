extends CharacterBody2D

var enemiesInRange= []
var enemyAttackCooldown = true
var health = 100
var playerAlive=true

var attackIP=false

const speed =100
var currentDirection= "down"

func _ready():
	$AnimatedSprite2D.play("frontIdle")

func _physics_process(delta):
	if playerAlive==false:
		updateDust()
		return

	enemiesInRange = enemiesInRange.filter(is_instance_valid)
	player_movement(delta)
	enemyAttack()
	attack()
	updateHealth()

	if health<=0 and playerAlive:
		playerDie()

	updateDust()

func player_movement(delta):

	if Input.is_action_pressed("ui_right"):
		currentDirection="right"
		playAnimation(1)
		velocity.x=speed
		velocity.y=0
	elif Input.is_action_pressed("ui_left"):
		currentDirection="left"
		playAnimation(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		currentDirection="down"
		playAnimation(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		currentDirection="up"
		playAnimation(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		playAnimation(0)
		velocity.x = 0
		velocity.y = 0

	move_and_slide()

func playAnimation(movement):
	var direction = currentDirection
	var animation = $AnimatedSprite2D

	if direction == "right":
		animation.flip_h = false
		if movement == 1:
			animation.play("sideWalk")
		elif movement == 0:
			if attackIP==false:
				animation.play("sideIdle")
	if direction == "left":
		animation.flip_h = true
		if movement == 1:
			animation.play("sideWalk")
		elif movement == 0:
			if attackIP==false:
				animation.play("sideIdle")
	if direction == "up":
		if movement == 1:
			animation.play("backWalk")
		elif movement == 0:
			if attackIP==false:
				animation.play("backIdle")
	if direction == "down":
		if movement == 1:
			animation.play("frontWalk")
		elif movement == 0:
			if attackIP==false:
				animation.play("frontIdle")


func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		if enemiesInRange.has(body) == false:
			enemiesInRange.append(body)

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemiesInRange.erase(body)

func player():
	pass

func enemyAttack():
	if enemiesInRange.size() > 0 and enemyAttackCooldown:
		health -= 15
		enemyAttackCooldown=false
		$attackCooldown.start()
		print(health)
		$regenTimer.start()


func _on_attack_cooldown_timeout():
	enemyAttackCooldown=true


func attack():
	var direction = currentDirection


	if Input.is_action_just_pressed("attack"):
		global.playerCurrentAttack=true
		attackIP= true
		if direction=="right":
			$AnimatedSprite2D.flip_h=false
			$AnimatedSprite2D.play("sideAtack")
			$dealAttackTimer.start()
		if direction=="left":
			$AnimatedSprite2D.flip_h=true
			$AnimatedSprite2D.play("sideAtack")
			$dealAttackTimer.start()
		if direction=="down":
			$AnimatedSprite2D.play("frontAtack")
			$dealAttackTimer.start()
		if direction=="up":
			$AnimatedSprite2D.play("backAtack")
			$dealAttackTimer.start()


func _on_deal_attack_timer_timeout() -> void:
	$dealAttackTimer.stop()
	global.playerCurrentAttack=false
	attackIP=false

func updateHealth():
	$healthBar.value=health
	$healthBar.visible = health < 100


func updateDust():
	var movementVelocity = get_real_velocity()
	$dustParticles.emitting = movementVelocity.length() > 0 and playerAlive
	if $dustParticles.emitting:
		$dustParticles.process_material.direction = Vector3(-movementVelocity.x, -movementVelocity.y, 0).normalized()


func _on_regen_timer_timeout() -> void:
	if not playerAlive:
		return
	if health<100:
		health+=15
		if health>100:
			health=100
	if health <= 0:
		health =0


func playerDie():
	playerAlive=false
	health = 0
	global.playerCurrentAttack = false
	$healthBar.visible=false
	updateDust()
	print("DEAD")
	$AnimatedSprite2D.play("dead")
	$deathTimer.start()


func _on_death_timer_timeout() -> void:
	global.resetGame()
	get_tree().reload_current_scene()
