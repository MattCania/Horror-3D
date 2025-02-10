extends Node

@onready var flashlight = $"."
@onready var spotlight3D = $SpotLight3D
var defaultLight = 0
var flashlightOn = false
var lerpSpeed = 5.0

func _ready():
	spotlight3D.light_energy = 0.0

func _input(event: InputEvent) -> void:
	# FlashLight Input
	if event.is_action_pressed("toggle_flashlight") || event.is_action_pressed("mouse_left"):
		if !flashlightOn:
			flashlightOn = true
			spotlight3D.light_energy = 50.0
		else:
			flashlightOn = false
			spotlight3D.light_energy = 0.0
		
