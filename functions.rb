require 'open-uri'
require 'nokogiri'
require 'csv'
require 'mongo'
require 'rubygems'
require 'write_xlsx'


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
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/tttttest#{index}")
  collection = client[:estabelecimentos]
  # hash.each do |key, value|
  #   collection.insert_one(value)
  # end
  # collection.find.each do |document|
  #   puts document
  # end
end

def question_a(index)
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/tttttest#{index}")
  collection = client[:estabelecimentos]

  actives = collection.find( { situacao_cadastral: '02' } ).count.to_f
  all = collection.count.to_f
  actives/all

end

def question_b(index)
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/tttttest#{index}")
  collection = client[:estabelecimentos]

  years = []
  restaurants = collection.find({cnae_fiscal_principal: { '$regex': /^561\d+$/ }})
  restaurants.each do |document|
    year = document['data_de_inicio_atividade'][0, 4]
    years.push(year) unless years.include?(year)
    next
  end

  dict = {}

  years.each do |year|
    year_restaurants = collection.find({data_de_inicio_atividade: { '$regex': /^#{year}\d+$/ }, cnae_fiscal_principal: { '$regex': /^561\d+$/ }})
    dict.store(year, year_restaurants.count.to_f)
  end
  dict
end

def export_xlsx(index, a, b)
  # Create a new Excel workbook
  workbook = WriteXLSX.new("respostas_#{index}.xlsx")

  # Add a worksheet
  worksheet = workbook.add_worksheet

  # Add and define a format
  format = workbook.add_format # Add a format
  format.set_bold
  format.set_color('red')
  # format.set_align('center')

  # Write a formatted and unformatted string, row and column notation.
  # col = row = 0
  # worksheet.write(row, col, "Hi Excel!", format)
  # worksheet.write(1,   col, "Hi Excel!")

  # Write a number and a formula using A1 notation
  worksheet.write('B2', 'A')
  worksheet.write('B3', 'B')
  worksheet.write('C2', a, format)
  worksheet.write('C3', b, format)

  workbook.close
end