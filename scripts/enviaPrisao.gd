# Este espaço envia o jogador para a prisão.
extends Espaco

class_name EnviaPrisao

# O índice do espaço da prisão no tabuleiro.
@export var indice_prisao: int = 10

# Sobrescreve a função da classe Espaco.
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	print("%s foi enviado para a prisão!" % jogador.nome)
	
	# Define a posição do jogador para a prisão.
	jogador.posicao = indice_prisao
	
	# Atualiza o estado do jogador para preso
	jogador.ir_para_prisao()
	
	# Aqui, idealmente, o peão do jogador seria movido visualmente para a prisão.
	# A lógica de "estar preso" será tratada no próprio script da Prisao e no Jogo.
