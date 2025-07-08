extends Node2D

@export var slime_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_position_x: float = 250.0
@export var spawn_position_y_min: float = 60.0
@export var spawn_position_y_max: float = 100.0

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	# Setup spawn timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_slime)
	spawn_timer.start()

func _spawn_slime() -> void:
	if slime_scene:
		var slime_instance = slime_scene.instantiate()
		# Random Y position within range
		var spawn_y = randf_range(spawn_position_y_min, spawn_position_y_max)
		slime_instance.position = Vector2(spawn_position_x, spawn_y)
		add_child(slime_instance)