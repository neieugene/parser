require "rubygems"
require "nokogiri"
require "open-uri"
require "csv"

$minDelay = 1 # минимальная задержка между запросами в секундах
$maxDelay = 2 # максимальная задержка между запросами в секундах

$products = {}

def createProduct?(title, price, image)
  product = [ title, price, image]
  if ($products[title].nil?)
    $products[title] = product
    puts "Found a new Product, with title: #{title}, price: #{price}"
    true
  else
    puts "End of work"
    false
  end
end

def parseProduct(url)
  sleep(rand($minDelay..$maxDelay))

  doc = Nokogiri::HTML(open(url))

  image = doc.xpath("//img[@id='bigpic']/@src").text()
  title = doc.xpath("//h1[@class='nombre_producto']").text.split().join(" ")

  elements = doc.xpath("//*[@data-qty]")
  elements.each do |element|
    size = element.xpath(".//span")[0].text
    price = (element.xpath(".//span")[1].text).split()[0]
    return false unless createProduct?(title + " - " + size, price, image)
  end
  true
end

def parseCategory(url)
  (1..100).each do |page|
    doc = Nokogiri::HTML(open(url + "?p=" + page.to_s))
    products = doc.xpath("//a[@class='product_img_link']/@href")
    products.each do |product|
      unless parseProduct(product.text)
        saveCSV
        return
      end
    end
  end
end

def saveCSV()
  puts "Saving data in csv file"
  CSV.open(ARGV[1], "wb") do |csv|
    csv << ["Название", "Цена", "Картинка"]
    $products.each { |title, product| csv << product }
  end
end

parseCategory(ARGV[0])

#  Example
#$ ruby parser.rb https://www.petsonic.com/snacks-huesos-para-perros/ data.csv
