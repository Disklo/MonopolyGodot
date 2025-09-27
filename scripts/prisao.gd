# Representa o espaço da prisão. O jogador pode estar visitando ou preso aqui.
extends Espaco

class_name Prisao

# Sobrescreve a função da classe Espaco.
func ao_parar(jogador: Jogador) -> void:
	# Esta função é chamada quando o jogador para aqui por movimento normal.
	# A lógica para quando o jogador É ENVIADO para a prisão é diferente.
	super.ao_parar(jogador)
	
	# Por enquanto, vamos assumir que se o jogador para aqui voluntariamente,
	# ele está apenas visitando.
	print("%s está apenas visitando a prisão." % jogador.nome)
	
	# A lógica para verificar se o jogador está preso, pagar fiança ou rolar dados
	# para sair seria mais complexa e adicionada no futuro.
	pass
