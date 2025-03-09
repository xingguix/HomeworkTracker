@tool
extends Panel
class_name SwitchButton

@onready var button = $"按钮"
@onready var icon = $Icon
@onready var show_icon = icon.get_node("show")
@onready var hide_icon = icon.get_node("hide")
@export var panel: Control
@export var text: String = "文本"
@onready var delete_all: TextureButton = $"../DeleteAll"
@export var disabled: bool = false:
	set(new_value):
		disabled = new_value
		if button:
			button.disabled = new_value

signal on_pressed(enable: bool)

func _process(delta):
	button.text = text

func _on_显示按钮_toggled(toggled_on):
	button.button_pressed = toggled_on
	if panel:
		panel.visible = toggled_on
	show_icon.visible = toggled_on
	hide_icon.visible = !toggled_on
	emit_signal("on_pressed", button.button_pressed)
