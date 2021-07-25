# Desafio Speedio 2021
Desafio de Data Ops do processo seletivo da Speedio 2021

# Guia

- Objetivo: Construir um data pipeline desde a extração, até o processamento e exibição. (a linguagem pode ser da sua escolha, se for RUBY ganha BONUS POINTS)
- Processo: Seguir os requisitos abaixo e ver minha explicação em video aqui
- Entrega: Colocar o codigo em um repositório público no gitlab ou github
- Projeto: Obter dados de empresas da Receita Federal, limpar e formatar os dados, realizar cruzamentos simples e gerar CSV com os dados

# Etapas

Código ler um dos arquivos em CSVs Dados Abertos CNPJ ESTABELECIMENTO XX da receita  (BONUS POINTS: ler todos os arquivos ESTABELECIMENTO) 
layout dos dados


Organizar os dados num hash/dicionario


Salvar no mongodb localmente ou em cloud MongoAtlas (gratuito)
Ler os dados do db e obter as seguintes informações:
- qual % das empresas estão ativas (SITUAÇÃO CADASTRAL)
- Quantas empresas do setor de restaurantes foram abertas em cada ano ? (prefixo do CNAE PRINCIPAL e DATA DE INÍCIO ATIVIDADE)(prefixo de restaurantes 56.1xxxxx, ex: 5611-2/03 é restaurante)
- BONUS POINTS: quantas empresas num raio de 5km do cep 01422000
- BONUS POINTS: tabela de correlação de CNAE FISCAL PRINCIPAL com os CNAE FISCAL SECUNDÁRIA


Exportar os dados do ponto 4 para um CSV (BONUS POINTS: exportar para formato excel)
