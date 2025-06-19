require 'nokogiri'
require 'open-uri'
require 'pry'

class CDKeysScraper
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

  class << self
    def execute
      LINK_IDENTIFIERS.each do |interest_price, ids|
        display_header(interest_price)

        ids.each do |id|
          page = Nokogiri::HTML(URI.open("#{PRIMARY_URL}/#{id}"))
                                  # Out of Stock ||  In Stock
          availability_matcher = /\w+\s+\w+\s+Stock|\w+\s+Stock/                                     
          availability = page.css("#product-details").first.children.text.match(availability_matcher )[0]
        
          
          name = page.css(".product-title").first&.text&.strip
          next out_of_stock_message(name) if availability == "Out of Stock"
          
          price = page.css(".final-price.inline-block").first&.text&.strip
          at_or_below_interest_price = (price.gsub("$", "").to_f) <= interest_price.to_f
          
          next display_not_at_rate(name, price) if !at_or_below_interest_price

          # note, region is behind knockout js library restriction
          # so can't be scraped from page directly
          display_results(name, price, availability, at_or_below_interest_price)
        end
      end
    end

    private

    
    def display_header(interest_price)
      newline(2)
      line_breaker_block(2) do
        puts "\s\sINTEREST PRICE RANGE OF #{interest_price}"
      end
    end
    
    def out_of_stock_message(name)
      newline_block do
        puts "- #{name} is not in stock"
      end
    end

    def display_not_at_rate(name, price)
      newline_block do 
        puts "- #{name} is available but at #{price}"
      end
    end
    
    def display_results(name, price, available, is_good_price)
      newline_block do
        puts ""
        puts "- Game: #{name} Price: #{price}"
        puts "Price is above marked interest price!"
      end
    end

    def line_breaker_block(times_to_perform = 1)
      line_breaker(times_to_perform)
      yield
      line_breaker(times_to_perform)
    end

    def newline_block(times_to_perform = 1)
      newline(times_to_perform)
      yield
      newline(times_to_perform)
    end

    def line_breaker(times_to_perform = 1)
      times_to_perform.times { puts "*" * 30 }
    end

    def newline(times_to_perform = 1)
      times_to_perform.times { puts "\n" }
    end
  end
end

CDKeysScraper.execute
