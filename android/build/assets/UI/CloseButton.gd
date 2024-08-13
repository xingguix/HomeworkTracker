extends TextureButton
class_name CloseButton

@export var target: Control

func _ready():
	if not target:
		target = $".."
	pressed.connect(Callable(self,"close"))

func close():
	target.hide()
