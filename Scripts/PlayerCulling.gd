extends Node3D

@onready var timer = $Timer

# var player_movement
# func _ready():
# 	var PlayerMovement = load("res://Scripts/PlayerMovement.gd")
# 	player_movement = PlayerMovement.new()

func _on_body_entered(body):
	if body.name == "Player" or body.name == "PlayerBody":
		print("Player Died...")
		Engine.time_scale = 0.25
		timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
