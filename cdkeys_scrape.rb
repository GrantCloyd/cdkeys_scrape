require 'nokogiri'
require 'open-uri'
#require 'pry'


PRIMARY_URL = "https://www.cdkeys.com".freeze
LINK_IDENTIFIERS = {
  "30" => ["god-of-war-ragnarok-pc-steam-na"],
  "25" => [
    "horizon-forbidden-west-complete-edition-pc-steam",
    "clair-obscur-expedition-33-pc-steam",
    "warhammer-40-000-space-marine-2-pc-steam",
    "the-hundred-line-last-defense-academy-pc-steam"
  ],
  "20" => [
      "outriders-complete-edition-pc-steam"
  ]
}.freeze

def execute 
  LINK_IDENTIFIERS.each do |interest_price, ids|
    display_header(interest_price)

    ids.each do |id|
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
end

def display_header(interest_price)
  newline(2)
  line_breaker(2)
  puts "\s\sINTEREST PRICE RANGE OF #{interest_price}"
  line_breaker(2)
end

def display_results(name, price, available, is_good_price)
  newline
  puts "- Game: #{name} Price: #{price}"
  puts "Available: #{available}"
  newline
  puts "Price is #{is_good_price ? "" : "NOT"} below marked interest price."
  newline
end

def line_breaker(times_to_perform = 1)
  times_to_perform.times { puts "*" * 30 }
end

def newline(times_to_perform = 1)
  times_to_perform.times { puts "\n" }
end

execute