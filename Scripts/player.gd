extends CharacterBody3D

var speed : float = 5.0
var sprintMultiplier: float = 2.0
var jumpVelocity: float = 4.5

#Inspector range
@export_range(1, 10, 0.5) var mouse_sens

#inspector area
@export var Camera: Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#dengan fungsi kamera ini, kamera tidak jitter
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (mouse_sens * 0.001))
		Camera.rotate_x(-event.relative.y * (mouse_sens * 0.001))
		Camera.rotation.x = clamp(Camera.rotation.x, -deg_to_rad(80), deg_to_rad(80))

#handle exit so I dont alt TAB animore
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var _currentSpeed = speed
	if Input.is_action_pressed("sprint"):
		_currentSpeed *= sprintMultiplier
	var target_vel = Vector3.ZERO
	if direction:
		velocity.x = direction.x * _currentSpeed
		velocity.z = direction.z * _currentSpeed
	# smooth interpolation (acceleration/deceleration)
	var accel := 10.0   # semakin besar semakin cepat merespons
	velocity.x = lerp(velocity.x, target_vel.x, accel * delta)
	velocity.z = lerp(velocity.z, target_vel.z, accel * delta)

	move_and_slide()
		# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity
		move_and_slide()
