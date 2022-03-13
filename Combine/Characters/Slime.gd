extends KinematicBody2D

var health = 100
var attack_power = 10
var sheepies = {}
var target_sheep
var rng = RandomNumberGenerator.new()
var speed = 4
var target_position


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
		if not target_position:
			var sheep = get_tree().get_nodes_in_group("Sheep")
			if sheep.size() > 0:
				target_position = sheep[rng.randi_range(0, sheep.size() - 1)].global_position
		moveTowards = target_position
	else:
		target_position = null
		moveTowards = get_target_sheep().global_position
	var direction = global_position.direction_to(moveTowards)
	var result = move_and_collide(direction * speed)

func attack():
	if sheepies.keys().size() < 1:
		return
	$AnimatedSprite.play("move")
	get_target_sheep().damage(attack_power)

# making this it's own method just because the code is ugly and I want to contain the ugly
func get_target_sheep():
	if not target_sheep or not is_instance_valid(target_sheep) or not target_sheep.name in sheepies.keys():
		target_sheep = sheepies[sheepies.keys()[rng.randi_range(0, sheepies.size() - 1)]]
	return target_sheep

func _on_AttackArea_body_entered(body):
	if $AttackTimer.is_stopped():
		$AttackTimer.start()
	if "Sheep" in body.name:
		sheepies[body.name] = body

func _on_AttackArea_body_exited(body):
	sheepies.erase(body.name)
	if sheepies.keys().size() < 1:
		$AttackTimer.stop()

func _on_AttackTimer_timeout():
	if sheepies.keys().size() < 1:
		return
	attack()
