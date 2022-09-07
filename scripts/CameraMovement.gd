extends Camera

var SPEED = 1.0
var look_at_prop = Vector3(0, 0, 0)

func _process(_delta):
	navigateCamera(_delta)


func navigateCamera(_delta):
	if Input.is_action_pressed("ui_right"):
		rotateXAxisAndLook(SPEED * _delta)		
	if Input.is_action_pressed("ui_left"):
		rotateXAxisAndLook(-SPEED * _delta)

func rotateXAxisAndLook(angle):
	transform = transform.rotated(Vector3.UP, angle)
	look_at ( look_at_prop, Vector3.UP )