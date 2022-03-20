extends Node2D


var number_of_sheep = 0
var number_of_slime = 0
var bounds = {}
var timeSinceLastCheck = 0.0
var outro = "null"
signal game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	bounds = get_bounds()
	$"/root/GlobalState".set_bounds(bounds)
	#$"/root/GlobalState".spawn_sheepy_bois(number_of_sheep)
	#$"/root/GlobalState".spawn_enemies(number_of_slime)
	$Player.set_bounds(bounds)
	var new_dialog = Dialogic.start('/Level03/intro')
	new_dialog.connect("timeline_end", self, "_on_timeline_end")
	connect("game_over", $"/root/GlobalState", "_on_game_over")
	add_child(new_dialog)
	get_tree().paused = true

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
			if $"/root/GlobalState".sheep_saved == 0:
				outro = Dialogic.start('/GenericLoss')
			elif $"/root/GlobalState".sheep_destroyed > 0:
				outro = Dialogic.start('/Level01/outro-bad')
			else:
				outro = Dialogic.start('/Level01/outro-good')
			outro.connect("timeline_end", self, "_on_outro_end")
			outro.connect("dialogic_signal", self, "_on_dialogic_signal")
			add_child(outro)
			get_tree().paused = true

func _on_timeline_end(timeline_name):
	print("END: ",timeline_name)
	get_tree().paused = false

func _on_outro_end(timeline_name):
	print("END: ",timeline_name)
	get_tree().paused = false
	emit_signal("game_over")

func _on_dialogic_signal(result):
	if result == "try_again":
		$"/root/GlobalState".reload_level()
	elif result == "next_level":
		$"/root/GlobalState".go_to_next_level()

