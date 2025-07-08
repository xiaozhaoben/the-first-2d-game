extends Node2D

@export var slime_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_position_x: float = 250.0
@export var spawn_position_y_min: float = 60.0
@export var spawn_position_y_max: float = 100.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var ui_manager: Control = $UIManager
@onready var player: CharacterBody2D = $Player

var score: int = 0
var high_score: int = 0
var is_paused: bool = false
var is_game_over: bool = false

# UI references
var pause_menu: Control
var game_over_menu: Control
var game_ui: Control
var score_label: Label
var high_score_label: Label

signal score_changed(new_score: int)
signal game_over_signal

func _ready() -> void:
	# Load high score first
	load_high_score()
	
	# Setup spawn timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_slime)
	spawn_timer.start()
	
	# Connect signals
	score_changed.connect(_on_score_changed)
	game_over_signal.connect(_on_game_over)
	
	# Connect player game over signal
	if player:
		player.player_died.connect(_on_player_died)
	
	# Wait one frame for all nodes to be ready, then setup UI
	call_deferred("setup_ui_after_ready")

func setup_ui_after_ready() -> void:
	print("Setting up UI after ready...")
	
	# Get UI references with error checking
	pause_menu = ui_manager.get_node("PauseMenu")
	game_over_menu = ui_manager.get_node("GameOverMenu")
	game_ui = ui_manager.get_node("GameUI")
	score_label = ui_manager.get_node("GameUI/ScoreLabel")
	high_score_label = ui_manager.get_node("GameUI/HighScoreLabel")
	
	print("UI nodes found:")
	print("- pause_menu: ", pause_menu != null)
	print("- game_over_menu: ", game_over_menu != null)
	print("- game_ui: ", game_ui != null)
	print("- score_label: ", score_label != null)
	print("- high_score_label: ", high_score_label != null)
	
	# Setup initial UI state
	setup_ui()
	
	# Connect buttons
	setup_button_connections()
	
	# Update score display
	update_score_display()

func setup_ui() -> void:
	# Show game UI
	if game_ui:
		game_ui.show()
		print("Game UI shown")
	
	# Hide menus
	if pause_menu:
		pause_menu.hide()
		print("Pause menu hidden")
	if game_over_menu:
		game_over_menu.hide()
		print("Game over menu hidden")

func setup_button_connections() -> void:
	print("Setting up button connections...")
	
	# Pause menu buttons
	var resume_button = ui_manager.get_node("PauseMenu/VBoxContainer/ResumeButton")
	var pause_restart_button = ui_manager.get_node("PauseMenu/VBoxContainer/RestartButton")
	var pause_quit_button = ui_manager.get_node("PauseMenu/VBoxContainer/QuitButton")
	
	print("Pause menu buttons found:")
	print("- resume_button: ", resume_button != null)
	print("- pause_restart_button: ", pause_restart_button != null)
	print("- pause_quit_button: ", pause_quit_button != null)
	
	if resume_button:
		if not resume_button.pressed.is_connected(resume_game):
			resume_button.pressed.connect(resume_game)
			print("Resume button connected")
	if pause_restart_button:
		if not pause_restart_button.pressed.is_connected(restart_game):
			pause_restart_button.pressed.connect(restart_game)
			print("Pause restart button connected")
	if pause_quit_button:
		if not pause_quit_button.pressed.is_connected(quit_game):
			pause_quit_button.pressed.connect(quit_game)
			print("Pause quit button connected")
	
	# Game over menu buttons
	var gameover_restart_button = ui_manager.get_node("GameOverMenu/VBoxContainer/RestartButton")
	var gameover_quit_button = ui_manager.get_node("GameOverMenu/VBoxContainer/QuitButton")
	
	print("Game over menu buttons found:")
	print("- gameover_restart_button: ", gameover_restart_button != null)
	print("- gameover_quit_button: ", gameover_quit_button != null)
	
	if gameover_restart_button:
		if not gameover_restart_button.pressed.is_connected(restart_game):
			gameover_restart_button.pressed.connect(restart_game)
			print("Game over restart button connected")
	if gameover_quit_button:
		if not gameover_quit_button.pressed.is_connected(quit_game):
			gameover_quit_button.pressed.connect(quit_game)
			print("Game over quit button connected")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		print("ESC pressed, toggling pause")
		toggle_pause()

func _spawn_slime() -> void:
	if slime_scene and not is_paused and not is_game_over:
		var slime_instance = slime_scene.instantiate()
		# Random Y position within range
		var spawn_y = randf_range(spawn_position_y_min, spawn_position_y_max)
		slime_instance.position = Vector2(spawn_position_x, spawn_y)
		
		# Connect slime death signal to score system
		if slime_instance.has_signal("slime_died"):
			slime_instance.slime_died.connect(_on_slime_killed)
		
		add_child(slime_instance)

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	
	# Check for new high score
	if score > high_score:
		high_score = score
		save_high_score()

func _on_score_changed(new_score: int) -> void:
	update_score_display()

func _on_slime_killed() -> void:
	add_score(10)

func _on_player_died() -> void:
	is_game_over = true
	spawn_timer.stop()
	game_over_signal.emit()

func _on_game_over() -> void:
	# Update final score
	var final_score_label = ui_manager.get_node("GameOverMenu/VBoxContainer/FinalScoreLabel")
	if final_score_label:
		final_score_label.text = "Final Score: " + str(score)
	
	# Show game over menu after a short delay
	await get_tree().create_timer(1.0).timeout
	if game_ui:
		game_ui.hide()
	if game_over_menu:
		game_over_menu.show()
	get_tree().paused = true

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	
	print("Toggle pause - is_paused: ", is_paused)
	print("pause_menu exists: ", pause_menu != null)
	
	if pause_menu:
		if is_paused:
			pause_menu.show()
			print("Pause menu should be visible now")
			print("Pause menu visible: ", pause_menu.visible)
		else:
			pause_menu.hide()
			print("Pause menu hidden")
	else:
		print("ERROR: pause_menu is null!")

func resume_game() -> void:
	print("Resume game called")
	is_paused = false
	get_tree().paused = false
	if pause_menu:
		pause_menu.hide()
		print("Game resumed, pause menu hidden")

func restart_game() -> void:
	print("Restart game called")
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game() -> void:
	print("Quit game called")
	get_tree().quit()

func update_score_display() -> void:
	if score_label:
		score_label.text = "Score: " + str(score)
	if high_score_label:
		high_score_label.text = "High Score: " + str(high_score)

func save_high_score() -> void:
	var save_file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	if save_file:
		save_file.store_32(high_score)
		save_file.close()

func load_high_score() -> void:
	var save_file = FileAccess.open("user://high_score.save", FileAccess.READ)
	if save_file:
		high_score = save_file.get_32()
		save_file.close()
	else:
		high_score = 0