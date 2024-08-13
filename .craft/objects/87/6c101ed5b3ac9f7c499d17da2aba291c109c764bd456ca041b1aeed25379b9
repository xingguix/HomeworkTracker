extends TextureButton

@export var textedit: TextEdit
@export var timer: Timer
@export var label: Label

func _on_pressed():
	DisplayServer.clipboard_set(textedit.text)
	label.show()
	timer.start()
	await timer.timeout
	label.hide()
