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
var merge_point = null
var merge_sheep = null
signal merge_to_sheep

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
	result[0].connect("merge_sheep", self, "_on_merge_sheep")
	result[0].connect("go_to_sheep", self, "_on_go_to_sheep")
	$"/root/GlobalState".connect("go_to_sheep", self, "_on_go_to_sheep")
	self.connect("merge_to_sheep", result[0], "_on_merge_to_sheep")
	
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
	if is_merging():
		var direction = global_position.direction_to(get_merge_point())
		return (direction + jitter) * speed
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

func _on_merge_sheep(centroid : Vector2):
	if is_selected():
		merge_sheep = null
		$MergeAnimation.stop()
		unsetMergeMask()
		merge_point = centroid
		$Sprite.material = null

func unsetMergeMask():
	$Merge.set_collision_mask_bit(0, false)

func is_merging():
	return  merge_point != null or merge_sheep != null

func get_merge_point():
	if merge_point != null and global_position.distance_to(merge_point) < 100:
		becomeMergeSheep()
	return merge_point if merge_sheep == null or not is_instance_valid(merge_sheep) else merge_sheep.global_position

func _on_go_to_sheep(sheep):
	if is_merging() and sheep.selection_id == selection_id:
		merge_sheep = sheep


func _on_Merge_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body != self and body.is_in_group("Sheep") and body.selection_id == selection_id and self == merge_sheep:
		$"/root/GlobalState".merge_sheep(self, body)

func becomeMergeSheep(selection = selection_id):
	selection_id = selection
	merge_point = null
	merge_sheep = self
	$Merge.set_collision_mask_bit(0, true)
	emit_signal("merge_to_sheep", self)
	$MergeAnimation.call_deferred("play", "Merge")
