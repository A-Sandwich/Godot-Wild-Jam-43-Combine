extends Node2D


var number_of_sheep = 3
const BOUNDS = Vector2(-1000, 1000)

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/GlobalState".set_bounds(BOUNDS)
	$"/root/GlobalState".spawn_sheepy_bois(number_of_sheep)
	$Player.set_bounds(BOUNDS)
