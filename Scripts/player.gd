extends CharacterBody2D

@export var move_speed : float = 50
@export var animator : AnimatedSprite2D
@export var bullet_scene : PackedScene

var is_game_over: bool = false

signal player_died

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !is_game_over and not get_tree().paused:
		velocity = Input.get_vector("left", "right", "up", "down") * move_speed
		if velocity == Vector2.ZERO:
			animator.play('idle')
		else:
			animator.play('run')
		move_and_slide()

func game_over():
	if is_game_over:
		return
		
	is_game_over = true
	animator.play("game_over")
	player_died.emit()
	
	# Play game over sound
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = preload("res://AssetBundle/Audio/GameOver.mp3")
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())

func _on_fire() -> void:
	if velocity != Vector2.ZERO || is_game_over || get_tree().paused:
		return
		
	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position + Vector2(6, 6)
	get_tree().current_scene.add_child(bullet_node)
	
	# Play gun sound
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = preload("res://AssetBundle/Audio/Gun.mp3")
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())