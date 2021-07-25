# Importin local file
require_relative 'functions'

# Database fields
fields =  ['cnpj_basico', 'cnpj_ordem', 'cnpj_dv', 'identificador matriz/filial', 'nome_fantasia',
           'situacao_cadastral', 'data_situacao_cadastral', 'motivo_situacao_cadastral',
           'nome_da_cidade_no_exterior', 'pais', 'data_de_inicio_atividade', 'cnae_fiscal_principal',
           'cnae_fiscal_secundaria', 'tipo_de_logradouro', 'logradouro', 'numero', 'complemento', 'bairro',
           'cep', 'uf', 'municipio', 'ddd_1', 'telefone_1', 'ddd_2', 'telefone_2', 'ddd_do_fax', 'fax',
           'correio_eletronico', 'situacao_especial', 'data_da_situacao_especial'
]

# To automatize the files generation, we'll create a list and use a For loop to make the generation 10 times with different indexes
list = [1,2,3,4,5,6,7,8,9,10]

list.each do |index|
  puts "Data #{index}."
  hash = generate_hash(index, fields)
  puts 'Hash generated!'
  store_mongo(index, hash)
  puts 'Data stored!'
  a = question_a(index)
  puts 'Question A made!'
  b = question_b(index)
  puts 'Question B made!'
  export_xlsx(index, a, b)
  puts "Data exported!\n"
end