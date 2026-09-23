extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	changeScenes()


func _on_cliff_side_exit_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transitionScene=true

func _on_cliff_side_exit_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transitionScene=false

func changeScenes():
	if global.transitionScene==true:
		if global.currentScene== "cliff_side":
			global.finishChangingScenes()
			get_tree().change_scene_to_file("res://sceens/world.tscn")
