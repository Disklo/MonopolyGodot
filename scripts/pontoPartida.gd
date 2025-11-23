# O jogador recebe um salário ao parar ou passar por aqui.
extends Espaco

class_name PontoPartida

# Valor que o jogador recebe ao passar pelo ponto de partida.
@export var salario: int = 200

# Esta função é chamada quando o jogador PARA exatamente no ponto de partida.
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	# A regra padrão é que o jogador recebe o salário dobrado se parar aqui,
	# mas vamos simplificar e dar o salário normal.
	
	# Chama o popup no Jogo
	var jogo = get_tree().get_root().get_node("Jogo")
	if jogo.has_method("exibir_popup_mensagem"):
		jogo.exibir_popup_mensagem("Você parou no Ponto de Partida!\nReceba R$ %d." % salario, func():
			jogador.receber(salario)
			if jogo.has_method("proximo_jogador"):
				jogo.proximo_jogador()
		)
	else:
		jogador.receber(salario)
