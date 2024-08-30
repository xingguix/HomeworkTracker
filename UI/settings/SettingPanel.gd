class_name SettingPanel extends Panel


var setting_scene: PackedScene = preload("res://UI/settings/setting.tscn")
@onready var settings_v_box: VBoxContainer = $SettingsVBox

func _ready():
	add_config()

func clear():
	for i in get_children():
		i.queue_free()

func add_setting_input(text: String, input: String):
	var setting = setting_scene.instantiate()
	setting.text = text
	setting.input = input
	settings_v_box.add_child(setting)

func add_config():
	var config: Dictionary = ConfigLoader.read_config()
	for i in config.keys():
		add_setting_input(i, config[i])

func save_config():
	var config: Dictionary
	for i in settings_v_box.get_children():
		if i is SettingInput:
			config[i.text] = i.input
	ConfigLoader.save_config(config)


func _on_close_button_pressed() -> void:
	save_config()
