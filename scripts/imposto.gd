# O jogador paga uma quantia fixa de imposto.
extends Espaco

class_name Imposto

# Valor do imposto a ser pago.
@export var valor_imposto: int = 200

# Sobrescreve a função da classe Espaco.
func ao_parar(jogador: Jogador) -> void:
	super.ao_parar(jogador)
	print("%s pagou R$%d de imposto." % [jogador.nome, valor_imposto])
	
	# Chama o popup no Jogo
	var jogo = get_tree().get_root().get_node("Jogo")
	if jogo.has_method("exibir_popup_mensagem"):
		jogo.exibir_popup_mensagem("Você caiu no Imposto.\nPague R$ %d ao banco." % valor_imposto, func():
			if jogo.has_method("verificar_falencia_obrigatoria"):
				if jogo.verificar_falencia_obrigatoria(jogador, valor_imposto):
					return

			jogador.pagar(valor_imposto)
			if jogo.has_method("proximo_jogador"):
				jogo.proximo_jogador()
		)
	else:
		jogador.pagar(valor_imposto)
