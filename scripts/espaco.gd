# Define a classe base para todos os espaços do tabuleiro.
extends Node2D

class_name Espaco

# Variáveis exportadas para serem configuradas no editor do Godot
@export var indice: int = 0

@export var nome: String = "Espaço"

@export var cor: Color = "CDE6D0"

@onready var nome_label: RichTextLabel = $NomeLabel
@onready var cor_espaco: ColorRect = $CorEspaco

func _ready() -> void:
	nome_label.text = nome
	cor_espaco.color = cor

# Função virtual que será chamada quando um jogador parar neste espaço.
# Cada tipo de espaço (propriedade, sorte, etc.) terá sua própria implementação.
func ao_parar(jogador: Jogador) -> void:
	# A keyword 'pass' significa que esta função não faz nada por enquanto.
	# Ela serve como um placeholder para ser sobrescrita pelas classes filhas.
	print("O jogador %s parou no espaço %s" % [jogador.nome, nome])
	pass
