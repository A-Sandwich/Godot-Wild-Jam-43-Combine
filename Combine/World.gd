extends Node2D


var sheepy_boi = load("res://Characters/Sheep.tscn")
var number_of_sheep = 100
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawn_sheepy_bois()


func spawn_sheepy_bois():
	for index in range(number_of_sheep):
		var sheep = sheepy_boi.instance()
		var scale = rng.randf_range(1.0, 2.0)
		sheep.scale = Vector2(scale, scale)
		sheep.global_position = Vector2(rng.randf_range(-1800, 3000), rng.randf_range(-1800, 1800))
		$Sheep.add_child(sheep)
