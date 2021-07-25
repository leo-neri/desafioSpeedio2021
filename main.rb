require_relative 'functions'

index = 1

fields =  ['cnpj_basico', 'cnpj_ordem', 'cnpj_dv', 'identificador matriz/filial', 'nome_fantasia',
           'situacao_cadastral', 'data_situacao_cadastral', 'motivo_situacao_cadastral',
           'nome_da_cidade_no_exterior', 'pais', 'data_de_inicio_atividade', 'cnae_fiscal_principal',
           'cnae_fiscal_secundaria', 'tipo_de_logradouro', 'logradouro', 'numero', 'complemento', 'bairro',
           'cep', 'uf', 'municipio', 'ddd_1', 'telefone_1', 'ddd_2', 'telefone_2', 'ddd_do_fax', 'fax',
           'correio_eletronico', 'situacao_especial', 'data_da_situacao_especial'
]

hash = generate_hash(index, fields)
store_mongo(index, hash)
a = question_a(index)
b = question_b(index)
export_xlsx(index, a, b)