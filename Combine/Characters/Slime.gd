extends KinematicBody2D

var health = 100
var attack_power = 10
var sheepies = {}
var target_entity
var rng = RandomNumberGenerator.new()
var speed = 4
signal enemy_clicked


func _ready():
	rng.randomize()
	$AnimatedSprite.play("idle")
	$HealthBar.value = health
	

func _process(delta):
	move()

func move():
	var moveTowards = Vector2.ZERO
	if sheepies.keys().size() < 1:
		if $AnimatedSprite.animation != "idle":
			$AnimatedSprite.play("idle")
	var target = get_target()
	if target == null:
		return
	moveTowards = target.global_position
	var direction = global_position.direction_to(moveTowards)
	var result = move_and_collide(direction * speed)

func attack():
	if sheepies.keys().size() < 1:
		return
	$AnimatedSprite.play("move")
	get_target_sheep().damage(attack_power)

func get_target():
	if rng.randi_range(1, 10) < 4:
		get_target_enemy()
	get_target_sheep()
	return target_entity

func get_target_enemy():
	if is_instance_valid(target_entity):
		return target_entity
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() < 1:
		return null
	var closest_enemy = null
	for enemy in enemies:
		if enemy == self:
			continue
		if not closest_enemy or global_position.distance_to(enemy.global_position) < global_position.distance_to(closest_enemy.global_position):
			closest_enemy = enemy
	target_entity = closest_enemy
	return closest_enemy

# making this it's own method just because the code is ugly and I want to contain the ugly
func get_target_sheep():
	if is_instance_valid(target_entity):
		return target_entity
	target_entity = null
	if sheepies.size() > 0 and (not target_entity or not target_entity.name in sheepies.keys()):
		target_entity = sheepies[sheepies.keys()[rng.randi_range(0, sheepies.size() - 1)]]
	if target_entity == null:
		var sheeps = get_tree().get_nodes_in_group("Sheep")
		if sheeps.size() > 0:
			target_entity = sheeps[rng.randi_range(0, sheeps.size() - 1)]
	return target_entity

func _on_AttackArea_body_entered(body):
	if $AttackTimer.is_stopped():
		$AttackTimer.start()
	if body.is_in_group("Sheep"):
		sheepies[body.name] = body
		target_entity = body
	elif body.is_in_group("enemy") and body.get_index() < get_index():
		merge(body)

func merge(enemy_to_merge):
	$"/root/GlobalState".spawn_enemy(global_position, scale.x + 1, health + enemy_to_merge.health)
	enemy_to_merge.queue_free()
	queue_free()

func _on_AttackArea_body_exited(body):
	sheepies.erase(body.name)
	if sheepies.keys().size() < 1:
		$AttackTimer.stop()

func _on_AttackTimer_timeout():
	if sheepies.keys().size() < 1:
		return
	if target_entity and is_instance_valid(target_entity):
		attack()
	else:
		target_entity = null

func _on_ClickArea_input_event(viewport, event, shape_idx):
	if event.is_action("right_click"):
		emit_signal("enemy_clicked", self)

func damage(damageAmount):
	$HealthBar.visible = true
	health -= damageAmount
	$HealthBar.value = health
	$AnimatedSprite.modulate.r = 1
	#$DamagePlayer.play_backwards("Damage")
	if health <= 0:
		queue_free()
