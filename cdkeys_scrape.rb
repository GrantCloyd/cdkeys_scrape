require 'nokogiri'
require 'open-uri'
#require 'pry'


PRIMARY_URL = "https://www.cdkeys.com".freeze
LINK_IDENTIFIERS = {
 "armored-core-vi-fires-of-rubicon-pc-steam" => 25,
  "god-of-war-ragnarok-pc-steam-na" => 30,
  "horizon-forbidden-west-complete-edition-pc-steam" => 25,
  "metaphor-refantazio-pc-steam" => 25 
}.freeze

def execute 
  LINK_IDENTIFIERS.each do |id, interest_price|
    page = Nokogiri::HTML(URI.open("#{PRIMARY_URL}/#{id}"))
  
    name = page.css(".item.product").first&.text
    price = page.css(".price").first&.text
    at_or_below_interest_price = (price.gsub("$", "").to_f) <= interest_price.to_f
    available = page.css(".product-usps-item.attribute.stock.available").first&.text
    
    # note, region is behind knockout js library restriction
    # so can't be scraped from page directly
    display_results(name, price, available, at_or_below_interest_price)
    
  
  end
end

def display_results(name, price, available, is_good_price)
  puts "*" * 10
  puts "Game: #{name} Price: #{price}"
  puts "Available: #{available}"
  puts "\n"
  puts "Price is #{is_good_price ? "" : "NOT"} below marked interest price."
  puts "*" * 10
  puts "\n"
end

execute