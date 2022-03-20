extends CanvasLayer

var should_show_merge_sheep = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused:
		$Button.visible = false
		$ResetLevel.visible = false
	else:
		if should_show_merge_sheep and get_parent().are_multiple_sheep_selected():
			$Button.visible = true
		$ResetLevel.visible = false
