extends KinematicBody2D

var health = 100
var attack_power = 3
var target_location = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var speed = 100
var previous_position = Vector2.ZERO
var jitter = Vector2.ZERO
var outline_shader = load("res://Characters/outline_shader.tres")
var stuck_position = Vector2.ZERO
const INT_MAX = 9223372036854775807
var selection_id = INT_MAX
var target_enemy = null
var target_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals()
	$Sprite.material = null
	rng.randomize()
	target_location = global_position
	previous_position = global_position
	offset_animation()
	$HealthBar.value = health

func connect_signals():
	var result = get_tree().get_nodes_in_group("Player")
	if result.size() < 1:
		return
	
	result[0].connect("left_click", self, "_on_left_click")
	result[0].connect("right_click", self, "_on_right_click")
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.connect("enemy_clicked", self, "_on_enemy_clicked")

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
	if target_enemy and is_instance_valid(target_enemy):
		target_location = target_enemy.global_position
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
	var previous = previous_position.distance_to(global_position) 
	if previous < .05:
		jitter = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
		if $Stuck.is_stopped():
			$Stuck.start()
			stuck_position = global_position

func choose_new_location():
	var range_change_x = rng.randi_range(-500, 500)
	var range_change_y = rng.randi_range(-500, 500)
	target_location = Vector2(global_position.x + range_change_x, global_position.y + range_change_y)
	jitter = Vector2.ZERO

func highlight():
	$Sprite.material = outline_shader

func unhighlight():
	$Sprite.material = null

func _on_left_click(selection_id):
	$Sprite.material = null
	self.selection_id = selection_id

func _on_right_click(new_position):
	if not is_selected():
		return
	target_location = new_position

func is_selected():
	# this might need to be a flag but I'm being lazy :)
	return $Sprite.material != null


func _on_Stuck_timeout():
	if stuck_position.distance_to(global_position) < 5:
		choose_new_location()

func damage(damageAmount):
	$HealthBar.visible = true
	$HealthBar/HealthTimer.start()
	health -= damageAmount
	$HealthBar.value = health
	$Sprite.modulate.r = 1
	$DamagePlayer.play_backwards("Damage")
	if health <= 0:
		queue_free()

func _on_DamagePlayer_animation_finished(anim_name):
	if not is_being_attacked():
		$DamagePlayer.stop()

func _on_Vision_body_entered(body):
	if body.is_in_group("enemy"):
		if target_enemy and is_instance_valid(target_enemy) and target_enemy == body:
			attack()
			target_in_range = true
			$AttackTimer.start()
		elif not target_enemy or not is_instance_valid(target_enemy):
			var direction = global_position.direction_to(body.global_position) * -1
			target_location = global_position + (direction * 1000)

func attack():
	target_enemy.damage(attack_power)

func _on_HealthTimer_timeout():
	$HealthBar.visible = false

func is_being_attacked():
	return $HealthBar.visible

func _on_enemy_clicked(enemy : KinematicBody2D):
	if is_selected():
		target_enemy = enemy

func _on_AttackTimer_timeout():
	if target_in_range:
		attack()
	else:
		$AttackTimer.stop()

func _on_Vision_body_exited(body):
	if body.is_in_group("enemy") and target_enemy and is_instance_valid(target_enemy) and body == target_enemy:
		target_in_range = false
