extends CharacterBody3D
# Gravity Variables (Deprecated Default Settings)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Tools
@onready var flashlight = $PlayerNeck/PlayerHead/Flashlight
@onready var blindlight = $PlayerNeck/PlayerHead/BlindLight

# Non Specific
@onready var playerBody = $"."

# Player Body Variables
@onready var playerHead = $PlayerNeck/PlayerHead
@onready var standingCollision = $StandingCollision
@onready var crouchingCollision = $CrouchingCollision
@onready var rayCast3D = $RayCast3D
@onready var playerNeck = $PlayerNeck
@onready var camera3D = $PlayerNeck/PlayerHead/ViewBobbing/Camera3D
@onready var viewBobbing = $PlayerNeck/PlayerHead/ViewBobbing

# Player Movement Variables
@export var baseSpeed = 5.0
var jumpStrength = 4.5
const walkSpeed = 4.0
const sprintSpeed = 7.5
const crouchSpeed = 2.5
var crouchDepth = -0.6
var freeLookTiltAmt = 7.5

# Sliding Variables
# var slidingTimer = 0.0
# var slidingDuration = 1.0
# var slideVector = Vector2.ZERO
# var slideSpeed = 10.0

# Head Bobbing Variables
const bobSpeedSprint = 22.0
const bobSpeedWalk = 14.0
const bobSpeedCrouch = 10.0

const bobSprintIntensity = 0.2
const bobWalkIntensity = 0.1
const bobCrouchIntensity = 0.05

var headBobbingVector = Vector2.ZERO
var headBobbingIndex = 0.0
var baseBobbingIntensity = 0.0

# States
var isWalking = false
var isCrouching = false
var isSprinting = false
var isFreeLooking = false
# var isSliding = false

# Specific Variables
var lerpSpeed = 10.0
var airLerpSpeed = 5.0
var direction = Vector3.ZERO

# Mouse Movement Variables
var mouseSensitivity = 0.3
var cursorVisibility = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cursorVisibility = false

# Mouse Mode Capturing
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tool_1"):
		flashlight.visible = false
		flashlight.process_mode = Node.PROCESS_MODE_DISABLED
		blindlight.visible = false
		blindlight.process_mode = Node.PROCESS_MODE_ALWAYS
	if event.is_action_pressed("tool_2"):
		flashlight.visible = true
		flashlight.process_mode = Node.PROCESS_MODE_INHERIT
		blindlight.visible = false
		blindlight.process_mode = Node.PROCESS_MODE_ALWAYS
	if event.is_action_pressed("tool_3"):
		flashlight.visible = false
		flashlight.process_mode = Node.PROCESS_MODE_DISABLED
		blindlight.visible = true
		blindlight.process_mode = Node.PROCESS_MODE_ALWAYS

# Mouse Motion Handling Events
func _input(event):
	if event is InputEventMouseMotion:
		if isFreeLooking:
			playerNeck.rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity))
			playerHead.rotate_x(deg_to_rad(-event.relative.y * mouseSensitivity))
			playerHead.rotation.x = clamp(playerHead.rotation.x, deg_to_rad(-70), deg_to_rad(70))
		
	if Input.is_action_just_pressed("ui_cancel"):
		if !cursorVisibility:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			cursorVisibility = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			cursorVisibility = false

# Player Movement Function
func _physics_process(delta):
	# Movement Inputs
	var input_dir = Input.get_vector("left_btn", "right_btn", "forward_btn", "backward_btn")
	
	# Check Crouch
	if Input.is_action_pressed("crouch_btn"): # || isSliding:
		baseSpeed = lerp(baseSpeed, crouchSpeed, delta * lerpSpeed)
		playerHead.position.y = lerp(playerHead.position.y, crouchDepth, delta * lerpSpeed)
			
		crouchingCollision.disabled = false
		standingCollision.disabled = true

#		if isSprinting && input_dir != Vector2.ZERO && is_on_floor():
#			slidingTimer = slidingDuration
#			slideVector = input_dir
#			isSliding = true
#			isFreeLooking = true
				
		isWalking = false
		isCrouching = true
		isSprinting = false

	# Check Sprint
	elif !rayCast3D.is_colliding():
		playerHead.position.y = lerp(playerHead.position.y, 0.0, delta * lerpSpeed)
		crouchingCollision.disabled = true
		standingCollision.disabled = false

		if Input.is_action_pressed("sprint_btn"):
			baseSpeed = lerp(baseSpeed, sprintSpeed, delta * lerpSpeed)
			isWalking = false
			isCrouching = false
			isSprinting = true

		else:
			baseSpeed = lerp(baseSpeed, walkSpeed, delta * lerpSpeed)
			isWalking = true
			isCrouching = false
			isSprinting = false

	# Free Looking Event
	if Input.is_action_pressed("free_look"): # || isSliding:
		isFreeLooking = true
		playerNeck.rotation.y = clamp(playerNeck.rotation.y, deg_to_rad(-100), deg_to_rad(100))
#		if isSliding:
#			camera3D.rotation.z = lerp(camera3D.rotation.z, -deg_to_rad(7.0), delta * lerpSpeed)
#		else:
#			camera3D.rotation.z = -deg_to_rad(playerNeck.rotation.y * freeLookTiltAmt)
	else:
		isFreeLooking = false
		playerNeck.rotation.y = lerp(playerNeck.rotation.y, 0.0, delta * lerpSpeed)
		camera3D.rotation.z = lerp(camera3D.rotation.z, 0.0, delta * lerpSpeed)
		
	# Sliding Event
#	if isSliding:
#		slidingTimer -= delta
#		if slidingTimer <= 0:
#			isSliding = false
#			isFreeLooking = false
			
# Handle Head Bobbing
	if isSprinting:
		baseBobbingIntensity = bobSprintIntensity
		headBobbingIndex += bobSpeedSprint * delta
	elif isWalking:
		baseBobbingIntensity = bobWalkIntensity
		headBobbingIndex += bobSpeedWalk * delta
	elif isCrouching:
		baseBobbingIntensity = bobCrouchIntensity
		headBobbingIndex += bobSpeedCrouch * delta
	
	if is_on_floor() && input_dir != Vector2.ZERO: # && !isSliding && input_dir != Vector2.ZERO:
		headBobbingVector.y = sin(headBobbingIndex)
		headBobbingVector.x = sin(headBobbingIndex / 2) + 0.5
		viewBobbing.position.y = lerp(viewBobbing.position.y, headBobbingVector.y * (baseBobbingIntensity / 2.0), delta * lerpSpeed) 
		viewBobbing.position.x = lerp(viewBobbing.position.x, headBobbingVector.x * baseBobbingIntensity, delta * lerpSpeed) 
	else:
		viewBobbing.position.y = lerp(viewBobbing.position.y, 0.0 , delta * lerpSpeed) 
		viewBobbing.position.x = lerp(viewBobbing.position.x, 0.0 , delta * lerpSpeed) 

	# Add Gravity Physics
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump_btn") and is_on_floor():
		velocity.y = jumpStrength
#		isSliding = false

	# Get Input Directions and Sliding Logic
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerpSpeed)
	else:
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * airLerpSpeed)
	
#	if isSliding:
#		direction = (transform.basis * Vector3(slideVector.x, 0, slideVector.y)).normalized()
#		baseSpeed = (slidingTimer + 0.5) * slideSpeed
		
	if direction:
		velocity.x = direction.x * baseSpeed
		velocity.z = direction.z * baseSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, baseSpeed)
		velocity.z = move_toward(velocity.z, 0, baseSpeed)

	move_and_slide()
