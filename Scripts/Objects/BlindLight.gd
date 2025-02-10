extends Node3D

@onready var spotlight3D = $SpotLight3D

var blindFlashOn = false
var blindFlashDuration = 0.1
var blindingTimer

var flashInCD = false
var blindCoolDown = 5.0
var cooldownTimer
var isFlickering = false
var flickerDuration = 0.2
var flicker

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_blind_flash") && !flashInCD || Input.is_action_just_pressed("mouse_right") && !flashInCD:
		if !blindFlashOn:
			blindFlashOn = true
			flashInCD = true
			cooldownTimer = blindCoolDown
			blindingTimer = blindFlashDuration
			spotlight3D.light_energy = 200.0
			spotlight3D.light_color = Color(100.0, 100.0, 50.0)
			
	if blindFlashOn:
		blindingTimer -= delta
		if blindingTimer <= 0:
			blindFlashOn = false
			spotlight3D.light_color = Color(0.788, 0.776, 0.671)
			spotlight3D.light_energy = 0
			
	if flashInCD:
		cooldownTimer -= delta
		if cooldownTimer <= 0:
			flashInCD = false
			isFlickering = true
			flicker = flickerDuration
	
	if isFlickering:
		spotlight3D.light_energy = 10.0
		flicker -= delta
		if flicker <= 0:
			isFlickering = false
			spotlight3D.light_energy = 0.0
			
			
