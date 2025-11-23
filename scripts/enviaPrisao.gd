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
	
	# Move visualmente o peão para a prisão
	var tabuleiro = get_tree().get_root().get_node("Jogo/Tabuleiro")
	var espaco_prisao = tabuleiro.obter_espaco(indice_prisao)
	
	if espaco_prisao != null:
		var offset = Vector2.ZERO
		match jogador.index:
			0: offset = Vector2(-30, -30)
			1: offset = Vector2(30, -30)
			2: offset = Vector2(-30, 30)
			3: offset = Vector2(30, 30)
			
		# Pode-se usar um tween para animar se desejar, mas o teleporte é aceitável para "ir para a prisão"
		# Vamos usar tween para ficar mais fluido
		var tween = create_tween()
		var destino = espaco_prisao.position + Vector2(200, 200) + offset
		tween.tween_property(jogador.peao, "position", destino, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
