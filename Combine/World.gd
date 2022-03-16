extends Node2D

var number_of_sheep = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/GlobalState".spawn_sheepy_bois(number_of_sheep)

