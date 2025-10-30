# Gerencia a coleção de espaços que compõem o tabuleiro.
extends Node

class_name Tabuleiro

# Array que conterá todos os nós de Espaco em ordem.
var espacos: Array[Espaco] = []

# A função _ready() é chamada pelo Godot quando o nó está pronto na cena.
func _ready() -> void:
	# Percorre todos os nós filhos do nó Tabuleiro
	for espaco_node in get_children():
		# Verifica se o filho é de fato um Espaco (para evitar erros)
		if espaco_node is Espaco:
			# Adiciona o espaço na nossa lista
			espacos.append(espaco_node)
			# Define o índice do espaço com base na sua posição na lista
			espaco_node.indice = espacos.size() - 1
	
	print("Tabuleiro inicializado com %d espaços." % espacos.size())


# Retorna o nó do espaço correspondente a um índice
func obter_espaco(indice: int) -> Espaco:
	if indice >= 0 and indice < espacos.size():
		return espacos[indice]
	else:
		print("Erro: Índice de espaço inválido: %d" % indice)
		return null

# Conta quantas propriedades de uma determinada cor existem no tabuleiro
func contar_propriedades_cor(cor_grupo: String) -> int:
	var contagem = 0
	for espaco in espacos:
		if espaco is Propriedade and espaco.cor_grupo == cor_grupo:
			contagem += 1
	return contagem
