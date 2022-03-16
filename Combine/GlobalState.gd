extends Node

var sheepy_boi = load("res://Characters/Sheep.tscn")
var slime = load("res://Characters/Slime.tscn")
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


func spawn_sheepy_bois(number_of_sheep):
	for index in range(number_of_sheep):
		var sheep = sheepy_boi.instance()
		var scale = rng.randf_range(1.0, 2.0)
		sheep.scale = Vector2(scale, scale)
		sheep.global_position = Vector2(rng.randf_range(-1800, 3000), rng.randf_range(-1800, 1800))
		get_tree().get_root().call_deferred("add_child", sheep)

func spawn_enemy(enemy_global_position, scale, health):
	var new_enemy = slime.instance()
	new_enemy.scale = Vector2(scale, scale)
	new_enemy.global_position = enemy_global_position
	new_enemy.attack_power = new_enemy.attack_power + 15 * scale
	new_enemy.health = health
	get_tree().get_root().call_deferred("add_child", new_enemy)
