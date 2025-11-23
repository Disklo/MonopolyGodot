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
			
			# Atribui o grupo de cor para propriedades baseado no índice (Monopoly Clássico)
			if espaco_node is Propriedade:
				var idx = espaco_node.indice
				if idx in [1, 3]:
					espaco_node.cor_grupo = "marrom"
				elif idx in [6, 8, 9]:
					espaco_node.cor_grupo = "azul_claro"
				elif idx in [11, 13, 14]:
					espaco_node.cor_grupo = "rosa"
				elif idx in [16, 18, 19]:
					espaco_node.cor_grupo = "laranja"
				elif idx in [21, 23, 24]:
					espaco_node.cor_grupo = "vermelho"
				elif idx in [26, 27, 29]:
					espaco_node.cor_grupo = "amarelo"
				elif idx in [31, 32, 34]:
					espaco_node.cor_grupo = "verde"
				elif idx in [37, 39]:
					espaco_node.cor_grupo = "azul_escuro"
				
				# Atualiza a cor visualmente
				espaco_node.atualizar_cor()
	
	colocar_valores_propriedades()
	print("Tabuleiro inicializado com %d espaços." % espacos.size())

func colocar_valores_propriedades() -> void:
	for espaco in espacos:
		var idx = espaco.indice
		
		# Configuração de Propriedades (Ruas)
		if espaco is Propriedade and not (espaco is Ferrovia or espaco is ServicoPublico):
			match idx:
				1: # Marrom 1
					espaco.preco = 60
					espaco.aluguel_base = 2
					espaco.alugueis = [2, 10, 30, 90, 160, 250] as Array[int]
					espaco.custo_casa = 50
				3: # Marrom 2
					espaco.preco = 60
					espaco.aluguel_base = 4
					espaco.alugueis = [4, 20, 60, 180, 320, 450] as Array[int]
					espaco.custo_casa = 50
				6: # Azul Claro 1
					espaco.preco = 100
					espaco.aluguel_base = 6
					espaco.alugueis = [6, 30, 90, 270, 400, 550] as Array[int]
					espaco.custo_casa = 50
				8: # Azul Claro 2
					espaco.preco = 100
					espaco.aluguel_base = 6
					espaco.alugueis = [6, 30, 90, 270, 400, 550] as Array[int]
					espaco.custo_casa = 50
				9: # Azul Claro 3
					espaco.preco = 120
					espaco.aluguel_base = 8
					espaco.alugueis = [8, 40, 100, 300, 450, 600] as Array[int]
					espaco.custo_casa = 50
				11: # Rosa 1
					espaco.preco = 140
					espaco.aluguel_base = 10
					espaco.alugueis = [10, 50, 150, 450, 625, 750] as Array[int]
					espaco.custo_casa = 100
				13: # Rosa 2
					espaco.preco = 140
					espaco.aluguel_base = 10
					espaco.alugueis = [10, 50, 150, 450, 625, 750] as Array[int]
					espaco.custo_casa = 100
				14: # Rosa 3
					espaco.preco = 160
					espaco.aluguel_base = 12
					espaco.alugueis = [12, 60, 180, 500, 700, 900] as Array[int]
					espaco.custo_casa = 100
				16: # Laranja 1
					espaco.preco = 180
					espaco.aluguel_base = 14
					espaco.alugueis = [14, 70, 200, 550, 750, 950] as Array[int]
					espaco.custo_casa = 100
				18: # Laranja 2
					espaco.preco = 180
					espaco.aluguel_base = 14
					espaco.alugueis = [14, 70, 200, 550, 750, 950] as Array[int]
					espaco.custo_casa = 100
				19: # Laranja 3
					espaco.preco = 200
					espaco.aluguel_base = 16
					espaco.alugueis = [16, 80, 220, 600, 800, 1000] as Array[int]
					espaco.custo_casa = 100
				21: # Vermelho 1
					espaco.preco = 220
					espaco.aluguel_base = 18
					espaco.alugueis = [18, 90, 250, 700, 875, 1050] as Array[int]
					espaco.custo_casa = 150
				23: # Vermelho 2
					espaco.preco = 220
					espaco.aluguel_base = 18
					espaco.alugueis = [18, 90, 250, 700, 875, 1050] as Array[int]
					espaco.custo_casa = 150
				24: # Vermelho 3
					espaco.preco = 240
					espaco.aluguel_base = 20
					espaco.alugueis = [20, 100, 300, 750, 925, 1100] as Array[int]
					espaco.custo_casa = 150
				26: # Amarelo 1
					espaco.preco = 260
					espaco.aluguel_base = 22
					espaco.alugueis = [22, 110, 330, 800, 975, 1150] as Array[int]
					espaco.custo_casa = 150
				27: # Amarelo 2
					espaco.preco = 260
					espaco.aluguel_base = 22
					espaco.alugueis = [22, 110, 330, 800, 975, 1150] as Array[int]
					espaco.custo_casa = 150
				29: # Amarelo 3
					espaco.preco = 280
					espaco.aluguel_base = 24
					espaco.alugueis = [24, 120, 360, 850, 1025, 1200] as Array[int]
					espaco.custo_casa = 150
				31: # Verde 1
					espaco.preco = 300
					espaco.aluguel_base = 26
					espaco.alugueis = [26, 130, 390, 900, 1100, 1275] as Array[int]
					espaco.custo_casa = 200
				32: # Verde 2
					espaco.preco = 300
					espaco.aluguel_base = 26
					espaco.alugueis = [26, 130, 390, 900, 1100, 1275] as Array[int]
					espaco.custo_casa = 200
				34: # Verde 3
					espaco.preco = 320
					espaco.aluguel_base = 28
					espaco.alugueis = [28, 150, 450, 1000, 1200, 1400] as Array[int]
					espaco.custo_casa = 200
				37: # Azul Escuro 1
					espaco.preco = 350
					espaco.aluguel_base = 35
					espaco.alugueis = [35, 175, 500, 1100, 1300, 1500] as Array[int]
					espaco.custo_casa = 200
					# Muda a cor do texto para branco para melhor contraste
					for label_name in ["NomeLabel", "PrecoLabel", "AluguelLabel", "NomeLabel2"]:
						if espaco.has_node(label_name):
							espaco.get_node(label_name).add_theme_color_override("default_color", Color.WHITE)
				39: # Azul Escuro 2
					espaco.preco = 400
					espaco.aluguel_base = 50
					espaco.alugueis = [50, 200, 600, 1400, 1700, 2000] as Array[int]
					espaco.custo_casa = 200
					# Muda a cor do texto para branco para melhor contraste
					for label_name in ["NomeLabel", "PrecoLabel", "AluguelLabel", "NomeLabel2"]:
						if espaco.has_node(label_name):
							espaco.get_node(label_name).add_theme_color_override("default_color", Color.WHITE)
			
			# Atualiza labels após mudar valores
			if espaco.has_node("PrecoLabel"):
				espaco.get_node("PrecoLabel").text = "Preço: R$" + espaco._format_preco(espaco.preco)
			if espaco.has_node("AluguelLabel"):
				espaco.get_node("AluguelLabel").text = "Aluguel: R$" + str(espaco.aluguel_base)
		
		# Configuração de Ferrovias
		elif espaco is Ferrovia:
			espaco.preco = 200
			espaco.alugueis = [25, 50, 100, 200] as Array[int]
			if espaco.has_node("PrecoLabel"):
				espaco.get_node("PrecoLabel").text = "Preço: R$200"
		
		# Configuração de Serviços Públicos
		elif espaco is ServicoPublico:
			espaco.preco = 150
			if espaco.has_node("PrecoLabel"):
				espaco.get_node("PrecoLabel").text = "Preço: R$150"
		
		# Configuração de Impostos
		elif espaco is Imposto:
			if idx == 4: # Imposto de Renda
				espaco.valor_imposto = 200
				if espaco.has_node("PrecoLabel"):
					espaco.get_node("PrecoLabel").text = "Pague R$200"
			elif idx == 38: # Imposto de Luxo
				espaco.valor_imposto = 100
				if espaco.has_node("PrecoLabel"):
					espaco.get_node("PrecoLabel").text = "Pague R$100"


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
