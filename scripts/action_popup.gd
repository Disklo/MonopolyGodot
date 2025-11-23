extends CanvasLayer

class_name ActionPopup

@onready var message_label: Label = $Content/PanelContainer/VBoxContainer/MessageLabel
@onready var button_container: HBoxContainer = $Content/PanelContainer/VBoxContainer/ButtonContainer

func _ready() -> void:
	hide_popup()

func set_text(text: String) -> void:
	message_label.text = text

func add_button(text: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = text
	# Carrega a fonte dinamicamente
	var font = load("res://assets/fonts/VCR_OSD_MONO_1.001.ttf")
	if font:
		btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 40)
	btn.custom_minimum_size = Vector2(150, 60)
	btn.pressed.connect(func():
		print("ActionPopup: Botão pressionado: ", text)
		callback.call()
		hide_popup()
	)
	button_container.add_child(btn)

func clear_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()

func show_popup() -> void:
	visible = true
	# Garante que o popup fique no topo

func hide_popup() -> void:
	visible = false
