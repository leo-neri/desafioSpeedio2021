# Required imports
require 'open-uri'
require 'nokogiri'
require 'csv'
require 'mongo'
require 'rubygems'
require 'write_xlsx'

# On the beginning, I made a function to get the download links and automatically do the downloads, but it wasn't a good practice,
# so I decided to discontinue. Besides it, I kept the function on the file.
def get_download_links
  # First we go to the website with URI
  html = URI.open("https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj")
  # After, Nokogiri will get the HTML document of the website
  doc = Nokogiri::HTML(html)
  final_array = []
  # For each "ESTABELECIMENTO" word in the site, we will append its link
  doc.xpath('//a[contains(text(), "ESTABELECIMENTO")]').map {|element| element["href"]}.compact.each do |element|
    final_array << element
  end
  final_array
end

# On the first used function, we will get the Hash data of the CSV
def generate_hash(index, fields)
  # First of all we'll read the CSV file, with some options:
  # - liberal_parsing -> The CSV have many abd data occurrences, so we'll take them out
  # - col_sep -> The default separator of CSV tool in Ruby is ",", and our data is separated by ";", so we need to change this
  # - encoding -> The default UTF-8 encoding of Ruby doesn't support Portuguese very well. ISO8859-1 fits better for us.
  data = CSV.read("data#{index}.csv", liberal_parsing: true,  :col_sep => ";", encoding: "ISO8859-1")
  # With the CSV reading, we can now create our hash that will be populated.
  dict = {}
  # For each row in CSV, we'll store the row number as a Key and its row as Value
  data.each_with_index do |row, _i|
    # We need to separate the fields of the Hash, so we'll use a For looping that will pass by every listed fields
    # and create a Hash with Key as the field name and Value as field value.
    new_dict = {}
    row.each_with_index do |field, _index|
      new_dict.store(fields[_index].to_sym, field)
    end
    # In the end, we'll store the minor Hash on the major Hash
    dict.store(_i, new_dict)
  end
  # Finally, we'll return the dict
  dict
end

# The next function will store the Hash data in our local mongodb
def store_mongo(index, hash)
  # First of all we need to connect do the database
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/speedioChallenge#{index}")
  # Now we'll go to the collection of Estabelecimentos
  collection = client[:estabelecimentos]
  # For each Value in our Hash, we'll insert it in the database
  hash.each do |_, value|
    collection.insert_one(value)
  end
end

# question_a refers to 4a) step, where we have to report the percentage of active Estabelecimentos
def question_a(index)
  # The start is the same of above function
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/speedioChallenge#{index}")
  collection = client[:estabelecimentos]
  # After make the connection and go to the right collection, we have to filter the Estabelecimentos with '02' at the
  # situacao_cadastral field with the .find method. Later, we have to count it and change class type to float
  actives = collection.find( { situacao_cadastral: '02' } ).count.to_f
  # Now we just count all the Estabelecimentos on the collection
  all = collection.count.to_f
  # By the end, we return the percentage
  actives/all

end

# question_b refers to 4b) step, where we have to report the number of restaurants opened in different years
def question_b(index)
  client = Mongo::Client.new("mongodb://127.0.0.1:27017/speedioChallenge#{index}")
  collection = client[:estabelecimentos]
  # First we'll query the Restaurants with regex rule to filter the rows with cnae_fiscal_principal starting
  # with 561
  restaurants = collection.find({cnae_fiscal_principal: { '$regex': /^561\d+$/ }})
  # To get the different years, we'll navigate by all the restaurants data_de_inicio_atividade fields and append the value
  # of year if its new on the list of reported years
  years = []
  restaurants.each do |document|
    # With indexation, the 4 first letters of the field value will be the year
    year = document['data_de_inicio_atividade'][0, 4]
    years.push(year) unless years.include?(year)
    next
  end

  # Now we'll check year-a-year the restaurants count result and append it to a dict
  dict = {}
  years.each do |year|
    year_restaurants = collection.find({data_de_inicio_atividade: { '$regex': /^#{year}\d+$/ }, cnae_fiscal_principal: { '$regex': /^561\d+$/ }})
    dict.store(year, year_restaurants.count.to_f)
  end
  dict
end

# The last function will export the data to a xlsx file
def export_xlsx(index, a, b)
  # First we create a new Excel workbook
  workbook = WriteXLSX.new("respostas_#{index}.xlsx")

  # After we'll add a worksheet
  worksheet = workbook.add_worksheet

  # Add and define a format to the answers
  format = workbook.add_format # Add a format
  format.set_bold
  format.set_color('red')

  # Writing the data
  worksheet.write('B2', 'A')
  worksheet.write('B3', 'B')
  worksheet.write('C2', a, format)
  worksheet.write('C3', b, format)

  # Saving and closing the file
  workbook.close
end