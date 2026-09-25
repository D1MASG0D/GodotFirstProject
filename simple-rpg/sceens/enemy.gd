extends CharacterBody2D

var speed = 60
var playerChase = false
var player= null

var health=100
var playerAttackZone=false
var canTakeDamage=true
var slimeAlive=true

func _physics_process(delta):
	if slimeAlive==false:
		return

	dealWithDamage()
	updateHealth()

	if playerChase:
		enemyChase()

		$AnimatedSprite2D.play("walk")

		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")

	if health <=0 and slimeAlive:
		slimeDie()

func enemyChase():
	velocity = (player.position - position).normalized() * speed
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		playerChase =true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		playerChase = false

func enemy():
	pass


func _on_enemyhitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		playerAttackZone=true

func _on_enemyhitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		playerAttackZone=false

func dealWithDamage():
	if playerAttackZone and global.playerCurrentAttack ==true:
		if canTakeDamage:
			health-=20
			if health < 0:
				health = 0
			$takeDamageCooldown.start()
			canTakeDamage=false
			print("Slime damaged: "+str(health)+" left")


func _on_take_damage_cooldown_timeout() -> void:
	canTakeDamage=true

func slimeDie():
	slimeAlive=false
	$CollisionShape2D.disabled = true
	$healthBar.visible=false
	print("Slime dead")
	$AnimatedSprite2D.play("death")
	$deathTimer.start()

func _on_death_timer_timeout() -> void:
	self.queue_free()

func updateHealth():
	$healthBar.value=health
	$healthBar.visible = health < 100
