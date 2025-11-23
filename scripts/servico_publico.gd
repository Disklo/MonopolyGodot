# Define um serviço público (ex: Companhia de Água, Eletricidade).
extends Propriedade

class_name ServicoPublico

# Referência ao nó do jogo para obter o valor dos dados.
var jogo: Jogo

func _ready() -> void:
	super._ready()
	# Tenta encontrar o nó Jogo na raiz
	var root = get_tree().root
	if root.has_node("Jogo"):
		jogo = root.get_node("Jogo")

# Sobrescreve a função de cobrar aluguel da classe Propriedade.
func cobrar_aluguel(jogador: Jogador) -> void:
	if dono == null:
		return
		
	if jogo == null:
		print("ERRO: Referência ao Jogo não encontrada em ServicoPublico.")
		return

	# O valor dos dados é pego da variável no script do jogo.
	var valor_dados = jogo.ultimo_resultado_dados
	
	# Conta quantos serviços o dono possui
	var num_servicos = 0
	for prop in dono.propriedades:
		if prop is ServicoPublico:
			num_servicos += 1
	
	# Regra: 4x se tiver 1, 10x se tiver 2
	var multiplicador = 4
	if num_servicos >= 2:
		multiplicador = 10
	
	var valor_a_pagar = valor_dados * multiplicador
	
	print("Serviço Público! O jogador %s tirou %d nos dados. Dono tem %d serviço(s). Paga %d * %d = R$%d." % [jogador.nome, valor_dados, num_servicos, valor_dados, multiplicador, valor_a_pagar])
	
	# Chama o popup no Jogo
	if jogo.has_method("exibir_popup_mensagem"):
		jogo.exibir_popup_mensagem("Você caiu no %s (Propriedade de %s).\nPague R$ %d (Dados %d x %d)." % [nome, dono.nome, valor_a_pagar, valor_dados, multiplicador], func():
			jogador.pagar(valor_a_pagar)
			dono.receber(valor_a_pagar)
			if jogo.has_method("proximo_jogador"):
				jogo.proximo_jogador()
		)
	else:
		jogador.pagar(valor_a_pagar)
		dono.receber(valor_a_pagar)
