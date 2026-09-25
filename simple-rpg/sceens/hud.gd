extends CanvasLayer

# One implementation of the HP text for both levels. The layer is instanced
# beside the level's `player`, so neither level script formats or pushes it.
# _ready() writes the first value, because a level created while the tree is
# paused gets no _process call until the player resumes.

func _ready():
	updateHealth()

func _process(delta: float) -> void:
	updateHealth()

func updateHealth():
	$HealthLabel.text = "HP: "+str(get_parent().get_node("player").health)
