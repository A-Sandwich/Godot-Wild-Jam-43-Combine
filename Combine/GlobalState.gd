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
const point_values = {
	sheep = 100,
	slime = 300,
	dead = -50
}
var total_sheep_saved = 0
var total_slimes_removed = 0
var total_sheep_destroyed = 0
var total_sheep_saved_game = 0
var total_slimes_removed_game = 0
var total_sheep_destroyed_game = 0
var level_index = 0


const levels = [
	"res://Levels/Level00.tscn",
	"res://Levels/Level01.tscn",
	"res://Levels/Level02.tscn",
	"res://Levels/Level03.tscn",
	"res://Levels/Level04.tscn"
]

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
		sheep.global_position = get_valid_global_position()
		get_tree().get_root().call_deferred("add_child", sheep)

func get_valid_global_position():
	var potential_position = Vector2(rng.randf_range(bounds["topLeft"].x, bounds["bottomRight"].x),
			rng.randf_range(bounds["topLeft"].y, bounds["bottomRight"].y))
	
	return potential_position


func spawn_enemy(enemy_global_position, scale, health):
	var new_enemy = slime.instance()
	new_enemy.scale = Vector2(scale, scale)
	new_enemy.global_position = enemy_global_position
	new_enemy.attack_power = new_enemy.attack_power + 15 * scale
	new_enemy.health = health
	get_tree().get_root().call_deferred("add_child", new_enemy)

func spawn_enemies(number_of_slimes):
	var new_enemy = slime.instance()
	new_enemy.global_position = get_valid_global_position()
	get_tree().get_root().call_deferred("add_child", new_enemy)

func merge_sheep(winning_sheep, losing_sheep):
	var sheep = sheepy_boi.instance()
	sheep.bounds = bounds
	var scale = winning_sheep.scale  + losing_sheep.scale
	sheep.scale = scale
	sheep.global_position = winning_sheep.global_position
	sheep.health = winning_sheep.health + losing_sheep.health
	sheep.health_total = sheep.health
	sheep.selection_id = winning_sheep.selection_id
	sheep.attack_power = winning_sheep.attack_power + losing_sheep.attack_power
	sheep.speed = winning_sheep.speed + losing_sheep.speed
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
	total_sheep_saved_game += sheep_saved
	total_slimes_removed_game += slimes_removed
	total_sheep_destroyed_game += sheep_destroyed
	emit_signal("game_over", get_point_total(), sheep_saved, sheep_destroyed, slimes_removed)

func save_sheep(sheep_name):
	sheep_saved += 1

func sheep_lost():
	sheep_destroyed += 1

func slime_destroyed():
	slimes_removed += 1

func get_point_total():
	var sheepies = sheep_saved * point_values["sheep"]
	var slimies = slimes_removed * point_values["slime"]
	var deadies = sheep_destroyed * point_values["dead"]
	return sheepies + slimies + deadies

func reset_values():
	sheep_saved = 0
	slimes_removed = 0
	sheep_destroyed = 0

func reload_level():
	get_tree().paused = false
	reset_values()
	get_tree().change_scene(levels[level_index])

func go_to_next_level():
	get_tree().paused = false
	reset_values()
	level_index += 1
	get_tree().change_scene(levels[level_index])
	
func end_game():
	sheep_saved = total_sheep_saved_game
	slimes_removed = total_slimes_removed_game
	sheep_destroyed = total_sheep_destroyed_game
	_on_game_over()
