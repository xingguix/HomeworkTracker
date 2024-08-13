extends TextureButton

@export var task: Task
@export var check_mark: TextureRect
var state: bool = false

func _on_pressed():
	state = !state
	check_mark.visible = state
	task.deleting = state
