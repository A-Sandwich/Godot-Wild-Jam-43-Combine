extends KinematicBody2D

var target_location = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var speed = 100
var previous_position = Vector2.ZERO
var jitter = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	target_location = global_position
	previous_position = global_position
	offset_animation()

func offset_animation():
	var timer_length = rng.randf_range(0.0, 0.75)
	yield(get_tree().create_timer(timer_length), "timeout")
	$AnimationPlayer.play("walk")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	previous_position = global_position
	if target_location.distance_to(global_position) <= 10:
		choose_new_location()
	move_and_slide(get_velocity())
	update_jitter()

func get_velocity():
	var direction = global_position.direction_to(target_location)
	update_sprite(direction)
	var velocity = (direction + jitter) * speed
	return velocity

func update_sprite(direction):
	if direction.x > 0:
		$Sprite.flip_h = true
	elif direction.x < 0:
		$Sprite.flip_h = false

func update_jitter():
	if previous_position == global_position:
		jitter = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))

func choose_new_location():
	var range_change_x = rng.randi_range(-500, 500)
	var range_change_y = rng.randi_range(-500, 500)
	target_location = Vector2(global_position.x + range_change_x, global_position.y + range_change_y)
	jitter = Vector2.ZERO
