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

# UI references - will be set after nodes are ready
var pause_menu: Control
var game_over_menu: Control
var game_ui: Control
var score_label: Label
var high_score_label: Label

signal score_changed(new_score: int)
signal game_over_signal

func _ready() -> void:
	# Wait for all nodes to be ready
	await get_tree().process_frame
	
	# Get UI references safely
	pause_menu = get_node_or_null("UIManager/PauseMenu")
	game_over_menu = get_node_or_null("UIManager/GameOverMenu")
	game_ui = get_node_or_null("UIManager/GameUI")
	score_label = get_node_or_null("UIManager/GameUI/ScoreLabel")
	high_score_label = get_node_or_null("UIManager/GameUI/HighScoreLabel")
	
	# Load high score
	load_high_score()
	
	# Setup spawn timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_slime)
	spawn_timer.start()
	
	# Connect signals
	score_changed.connect(_on_score_changed)
	game_over_signal.connect(_on_game_over)
	
	# Setup UI
	update_score_display()
	setup_ui()
	
	# Connect player game over signal
	if player:
		player.player_died.connect(_on_player_died)
	
	# Connect UI buttons
	setup_button_connections()

func setup_ui() -> void:
	# Show game UI
	if game_ui:
		game_ui.show()
	
	# Hide menus
	if pause_menu:
		pause_menu.hide()
	if game_over_menu:
		game_over_menu.hide()

func setup_button_connections() -> void:
	# Pause menu buttons
	var resume_button = get_node_or_null("UIManager/PauseMenu/VBoxContainer/ResumeButton")
	var pause_restart_button = get_node_or_null("UIManager/PauseMenu/VBoxContainer/RestartButton")
	var pause_quit_button = get_node_or_null("UIManager/PauseMenu/VBoxContainer/QuitButton")
	
	if resume_button:
		resume_button.pressed.connect(resume_game)
	if pause_restart_button:
		pause_restart_button.pressed.connect(restart_game)
	if pause_quit_button:
		pause_quit_button.pressed.connect(quit_game)
	
	# Game over menu buttons
	var gameover_restart_button = get_node_or_null("UIManager/GameOverMenu/VBoxContainer/RestartButton")
	var gameover_quit_button = get_node_or_null("UIManager/GameOverMenu/VBoxContainer/QuitButton")
	
	if gameover_restart_button:
		gameover_restart_button.pressed.connect(restart_game)
	if gameover_quit_button:
		gameover_quit_button.pressed.connect(quit_game)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_game_over:
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
	var final_score_label = get_node_or_null("UIManager/GameOverMenu/VBoxContainer/FinalScoreLabel")
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
	
	if pause_menu:
		if is_paused:
			pause_menu.show()
		else:
			pause_menu.hide()

func resume_game() -> void:
	print("Resume game called")  # Debug print
	is_paused = false
	get_tree().paused = false
	if pause_menu:
		pause_menu.hide()

func restart_game() -> void:
	print("Restart game called")  # Debug print
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game() -> void:
	print("Quit game called")  # Debug print
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