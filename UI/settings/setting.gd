class_name SettingInput extends HBoxContainer

@onready var line_edit = $LineEdit
@onready var label = $Label

var text: String
var input: String

func _ready():
	label.text = text
	line_edit.text = input

func _physics_process(delta):
	input = line_edit.text
