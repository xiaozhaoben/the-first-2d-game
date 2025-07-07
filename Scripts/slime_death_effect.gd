extends Node2D

func _ready() -> void:
	# Auto-destroy after animation completes
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	queue_free()