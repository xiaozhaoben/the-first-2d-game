extends Area2D

@export var slime_speed : float = -100
@export var health: int = 1

var death_effect_scene = preload("res://Scenes/slime_death_effect.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(slime_speed, 0) * delta
	
	# Remove slime if it goes too far left
	if position.x < -300:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("hit Player, game over")
		body.game_over()

func take_damage() -> void:
	health -= 1
	if health <= 0:
		die()

func die() -> void:
	# Create death effect
	if death_effect_scene:
		var death_effect = death_effect_scene.instantiate()
		death_effect.position = position
		get_tree().current_scene.add_child(death_effect)
	
	# Play death sound if available
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = preload("res://AssetBundle/Audio/EnemyDeath.mp3")
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	
	# Remove audio player after sound finishes
	audio_player.finished.connect(func(): audio_player.queue_free())
	
	queue_free()