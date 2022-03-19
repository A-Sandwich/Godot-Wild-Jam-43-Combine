extends Node

var sheepy_boi = load("res://Characters/Sheep.tscn")
var slime = load("res://Characters/Slime.tscn")
var rng = RandomNumberGenerator.new()
var bounds = {}
signal go_to_sheep
signal game_over
var sheep_saved = 0
var slimes_removed = 0
var sheep_destroyed = 0
var points_per_sheep = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func set_bounds(bounds):
	self.bounds = bounds

func spawn_sheepy_bois(number_of_sheep):
	for index in range(number_of_sheep):
		var sheep = sheepy_boi.instance()
		sheep.bounds = bounds
		var scale = rng.randf_range(1.0, 2.0)
		sheep.scale = Vector2(scale, scale)
		sheep.global_position = Vector2(rng.randf_range(bounds["topLeft"].x, bounds["bottomRight"].x),
			rng.randf_range(bounds["topLeft"].y, bounds["bottomRight"].y))
		get_tree().get_root().call_deferred("add_child", sheep)

func spawn_enemy(enemy_global_position, scale, health):
	var new_enemy = slime.instance()
	new_enemy.scale = Vector2(scale, scale)
	new_enemy.global_position = enemy_global_position
	new_enemy.attack_power = new_enemy.attack_power + 15 * scale
	new_enemy.health = health
	get_tree().get_root().call_deferred("add_child", new_enemy)

func merge_sheep(winning_sheep, losing_sheep):
	var sheep = sheepy_boi.instance()
	sheep.bounds = bounds
	var scale = winning_sheep.scale  + losing_sheep.scale
	sheep.scale = scale
	sheep.global_position = winning_sheep.global_position
	sheep.health = winning_sheep.health + losing_sheep.health
	sheep.selection_id = winning_sheep.selection_id
	sheep.attack_power = winning_sheep.attack_power + losing_sheep.attack_power
	winning_sheep.unsetMergeMask()
	winning_sheep.global_position = Vector2(-1000000000, 10000000000)
	losing_sheep.global_position = Vector2(1000000000, 10000000000)
	winning_sheep.queue_free()
	losing_sheep.queue_free()
	get_tree().get_root().call_deferred("add_child", sheep)
	sheep.call_deferred("becomeMergeSheep")
	emit_signal("go_to_sheep", sheep)

func clamp_vector(position : Vector2, bounds : Vector2):
	var x = clamp(position.x, bounds.x, bounds.y)
	var y = clamp(position.x, bounds.x, bounds.y)
	return Vector2(x, y)

func _on_game_over():
	emit_signal("game_over", points_per_sheep * sheep_saved)

func sheep_saved(sheep_name):
	sheep_saved += 1
