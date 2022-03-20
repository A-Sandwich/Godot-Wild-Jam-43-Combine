extends Node2D


var number_of_sheep = 3
var bounds = {}
var timeSinceLastCheck = 0.0
var outro = null
signal game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	bounds = get_bounds()
	$"/root/GlobalState".set_bounds(bounds)
	$"/root/GlobalState".spawn_sheepy_bois(number_of_sheep)
	$Player.set_bounds(bounds)
	var new_dialog = Dialogic.start('/Level00/intro')
	new_dialog.connect("timeline_end", self, "_on_timeline_end")
	connect("game_over", $"/root/GlobalState", "_on_game_over")
	add_child(new_dialog)
	get_tree().paused = true
	$Player/HUD.should_show_merge_sheep = false

func get_bounds():
	return {
		"topLeft" : $Bounds/TopLeft.transform.get_origin(),
		"bottomRight" : $Bounds/BottomRight.transform.get_origin()
	}

func _process(delta):
	timeSinceLastCheck += delta
	if timeSinceLastCheck > 1 and get_tree().get_nodes_in_group("sheep").size() < 1:
		timeSinceLastCheck = 0
		if outro == null:
			outro = Dialogic.start('/Level00/Outro')
			outro.connect("timeline_end", self, "_on_outro_end")
			add_child(outro)
			get_tree().paused = true

func _on_timeline_end(timeline_name):
	print("END: ",timeline_name)
	get_tree().paused = false

func _on_outro_end(timeline_name):
	print("END: ",timeline_name)
	get_tree().paused = false
	emit_signal("game_over")
