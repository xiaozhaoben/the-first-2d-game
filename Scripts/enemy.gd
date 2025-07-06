extends Area2D

@export var slime_speed : float = -100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(-100, 0) * delta


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("hit Player, game over")
		body.game_over()
