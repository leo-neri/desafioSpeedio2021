require 'open-uri'
require 'nokogiri'
require 'csv'


def get_download_links
  html = URI.open("'https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj'")
  doc = Nokogiri::HTML(html)
  final_array = []

  doc.xpath('//a[contains(text(), "ESTABELECIMENTO")]').map {|element| element["href"]}.compact.each do |element|
    final_array << element
  end

  final_array
end

puts get_download_links