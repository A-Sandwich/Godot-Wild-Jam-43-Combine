extends Node2D


var number_of_sheep = 3
var bounds = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	bounds = get_bounds()
	$"/root/GlobalState".set_bounds(bounds)
	$"/root/GlobalState".spawn_sheepy_bois(number_of_sheep)
	$Player.set_bounds(bounds)

func get_bounds():
	return {
		"topLeft" : $Bounds/TopLeft.transform.get_origin(),
		"bottomRight" : $Bounds/BottomRight.transform.get_origin()
	}
