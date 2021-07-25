require 'open-uri'
require 'nokogiri'
require 'csv'
require 'mongo'



def get_download_links
  html = URI.open("https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj")
  doc = Nokogiri::HTML(html)
  final_array = []
  doc.xpath('//a[contains(text(), "ESTABELECIMENTO")]').map {|element| element["href"]}.compact.each do |element|
    final_array << element
  end
  final_array
end

def generate_hash(index, fields)
  data = CSV.read("data00#{index}.csv", liberal_parsing: true,  :col_sep => ";")
  dict = {}
  data.each_with_index do |row, _i|
    new_dict = {}
    row.each_with_index do |campo, _index|
      new_dict.store(fields[_index].to_sym, campo)
    end
    dict.store(_i, new_dict)
  end
  dict
end

def store_mongo(index, hash)
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/tttest#{index}")
  collection = client[:estabelecimentos]
  # hash.each do |key, value|
  #   collection.insert_one(value)
  # end
  # collection.find.each do |document|
  #   puts document
  # end
end

def question_a(index)
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/tttest#{index}")
  collection = client[:estabelecimentos]

  actives = collection.find( { situacao_cadastral: '02' } ).count.to_f
  all = collection.count.to_f
  percentage = actives/all
  percentage
end

def question_b(index)
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/tttest#{index}")
  collection = client[:estabelecimentos]

  cnae = collection.find({cnae_fiscal_principal: { '$regex': /^561\d+$/ }})
  cnae.find.each do |document|
    puts document
  end

end