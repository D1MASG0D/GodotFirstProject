extends CharacterBody2D

var enemyInAttackRange= false
var enemyAttackCooldown = true
var health = 100
var playerAlive=true

var attackIP=false

const speed =100
var currentDirection= "none"

func _ready():
	$AnimatedSprite2D.play("frontIdle")

func _physics_process(delta):
	player_movement(delta)
	enemyAttack()
	attack()
	updateHealt()
	
	if health<=0:
		playerAlive=false
		health = 0
		print("DEAD")
		self.queue_free()
		
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
		enemyInAttackRange=true
	
func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemyInAttackRange=false

func player():
	pass
	
func enemyAttack():
	if enemyInAttackRange and enemyAttackCooldown:
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

func updateHealt():
	var healthBar= $healthBar
	healthBar.value=health
	if health >= 100:
		healthBar.visible = false
	else:
		healthBar.visible = true


func _on_regen_timer_timeout() -> void:
	if health<100:
		health+=15
		if health>100:
			health=100
	if health <= 0:
		health =0
