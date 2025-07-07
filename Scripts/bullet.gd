extends Area2D

@export var bullet_speed : float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect area entered signal for collision detection
	area_entered.connect(_on_area_entered)
	
	# Auto-destroy bullet after 3 seconds
	await get_tree().create_timer(3).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(bullet_speed, 0) * delta

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit a slime enemy
	if area.has_method("take_damage"):
		area.take_damage()
		queue_free()  # Destroy bullet on hit