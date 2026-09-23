extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if global.gameFirstLoading==true:
		$player.position.x = global.playerStart_posX
		$player.position.y = global.playerStart_posY
	else:
		$player.position.x = global.playerExitCliffSide_posX
		$player.position.y = global.playerExitCliffSide_posY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ChangeScene()


func _on_cliff_side_transition_body_entered(body):
	if body.has_method("player"):
		global.transitionScene=true

func _on_cliff_side_transition_body_exited(body):
	if body.has_method("player"):
		global.transitionScene=false

func ChangeScene():
	if global.transitionScene ==true:
		if global.currentScene=="world":
			global.finishChangingScenes()
			global.gameFirstLoading=false
			get_tree().change_scene_to_file("res://sceens/cliff_side.tscn")
