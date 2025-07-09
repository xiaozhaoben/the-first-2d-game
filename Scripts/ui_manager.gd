extends Control

func _ready() -> void:
	# Add this node to the ui_manager group for easier finding
	add_to_group("ui_manager")
	print("UIManager ready and added to group")