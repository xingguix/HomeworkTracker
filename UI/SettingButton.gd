extends TextureButton

@export var setting_panel: Control

func _on_pressed():
	setting_panel.visible = not setting_panel.visible
