extends Control

class_name JogadorHUD

@onready var nome_label: Label = $PanelContainer/HBoxContainer/VBoxContainer/NomeLabel
@onready var dinheiro_label: Label = $PanelContainer/HBoxContainer/VBoxContainer/DinheiroLabel
@onready var avatar_texture: TextureRect = $PanelContainer/HBoxContainer/AvatarTextureRect
@onready var cor_indicador: Panel = $PanelContainer/HBoxContainer/CorIndicador

func setup(nome: String, cor: Color) -> void:
	nome_label.text = nome
	
	# Configura o indicador de cor
	var style = StyleBoxFlat.new()
	style.bg_color = cor
	style.set_corner_radius_all(50) # Faz um círculo
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color.BLACK
	
	cor_indicador.add_theme_stylebox_override("panel", style)

func atualizar_dinheiro(valor: int) -> void:
	dinheiro_label.text = "Dinheiro: R$ %d" % valor
