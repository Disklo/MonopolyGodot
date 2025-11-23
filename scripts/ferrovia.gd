# Define uma ferrovia, um tipo de propriedade especial.
extends Propriedade

class_name Ferrovia

# O aluguel aumenta com o número de ferrovias possuídas.

# Sobrescreve a função de cobrar aluguel da classe Propriedade.
func cobrar_aluguel(jogador: Jogador) -> void:
	# Verifica se o dono existe.
	if dono == null:
		return

	# Conta quantas ferrovias o dono possui.
	var num_ferrovias = 0
	for prop in dono.propriedades:
		# Verifica se a propriedade é do tipo Ferrovia.
		if prop is Ferrovia:
			num_ferrovias += 1
	
	# Calcula o aluguel com base no número de ferrovias.
	var aluguel_a_cobrar = alugueis[num_ferrovias - 1]
	
	print("%s possui %d ferrovia(s). O aluguel é de R$%d." % [dono.nome, num_ferrovias, aluguel_a_cobrar])
	
	# Chama o popup no Jogo
	var jogo = get_tree().get_root().get_node("Jogo")
	if jogo.has_method("exibir_popup_mensagem"):
		jogo.exibir_popup_mensagem("Você caiu na %s (Propriedade de %s).\nPague R$ %d de aluguel." % [nome, dono.nome, aluguel_a_cobrar], func():
			jogador.pagar(aluguel_a_cobrar)
			dono.receber(aluguel_a_cobrar)
			if jogo.has_method("proximo_jogador"):
				jogo.proximo_jogador()
		)
	else:
		jogador.pagar(aluguel_a_cobrar)
		dono.receber(aluguel_a_cobrar)
