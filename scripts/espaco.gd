# Define a classe base para todos os espaços do tabuleiro.
extends Node

class_name Espaco

# Variáveis exportadas para serem configuradas no editor do Godot
@export var indice: int = 0
@export var nome: String = "Espaço"

# Função virtual que será chamada quando um jogador parar neste espaço.
# Cada tipo de espaço (propriedade, sorte, etc.) terá sua própria implementação.
func ao_parar(jogador: Jogador) -> void:
	# A keyword 'pass' significa que esta função não faz nada por enquanto.
	# Ela serve como um placeholder para ser sobrescrita pelas classes filhas.
	print("O jogador %s parou no espaço %s" % [jogador.nome, nome])
	pass
