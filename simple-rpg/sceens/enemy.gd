extends CharacterBody2D

var speed = 40
var playerChase = false
var player= null

var health=100
var playerAttackZone=false
var canTakeDamage=true

func _physics_process(delta):
	dealWithDamage()
	
	if playerChase:
		position += (player.position - position)/speed
		
		$AnimatedSprite2D.play("walk")
		
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	playerChase =true

func _on_detection_area_body_exited(body: Node2D) -> void:
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
			$takeDamageCooldown.start()
			canTakeDamage=false
			print("Slime damaged: "+str(health)+" left")
		if health <=0:
			self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	canTakeDamage=true
