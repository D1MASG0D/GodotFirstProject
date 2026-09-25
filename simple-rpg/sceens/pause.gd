extends CanvasLayer

# Layer 20 of the structure in the planning note. process_mode is set to Always
# in the scene, because one node has to listen to the pause action in both
# states: while the game runs to pause it, and while it is paused to resume.
# _ready() matches the overlay to the tree, so a level created while the tree is
# already paused shows it instead of waiting for a key press it never gets.

func _ready():
	visible = get_tree().paused


func _input(event):
	if event.is_action_pressed("pause"):
		togglePause()


func togglePause():
	var paused = not get_tree().paused
	get_tree().paused = paused
	visible = paused
