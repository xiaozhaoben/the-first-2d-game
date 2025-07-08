extends Control

@onready var game_manager = get_parent()
@onready var pause_menu = $PauseMenu
@onready var game_over_menu = $GameOverMenu
@onready var final_score_label = $GameOverMenu/VBoxContainer/FinalScoreLabel

func _ready() -> void:
	# Connect button signals
	$PauseMenu/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$PauseMenu/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$PauseMenu/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	$GameOverMenu/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$GameOverMenu/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Connect to game manager signals
	if game_manager:
		game_manager.game_over_signal.connect(_on_game_over)

func _on_resume_pressed() -> void:
	game_manager.resume_game()

func _on_restart_pressed() -> void:
	game_manager.restart_game()

func _on_quit_pressed() -> void:
	game_manager.quit_game()

func _on_game_over() -> void:
	if final_score_label and game_manager:
		final_score_label.text = "Final Score: " + str(game_manager.score)