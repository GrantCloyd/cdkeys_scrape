# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'

class CDKeysScraper
  LINK_IDENTIFIERS = {
    '30' => ['god-of-war-ragnarok-pc-steam-na'],
    '25' => [
      'horizon-forbidden-west-complete-edition-pc-steam',
      'clair-obscur-expedition-33-pc-steam',
      'warhammer-40-000-space-marine-2-pc-steam',
      'the-hundred-line-last-defense-academy-pc-steam'
    ],
    '20' => [
        'outriders-complete-edition-pc-steam'
    ]
  }.freeze

  class << self
    def execute
      LINK_IDENTIFIERS.each do |interest_price, url_ids|
        display_price_header(interest_price)

        url_ids.each do |url_id|
          game_information = GameInformation.new(url_id, interest_price)

          game_information.display_price_and_stock_information
        end
      end
    end

    private

    def display_price_header(interest_price)
      puts "\n"
      line_breaker_block(2) do
        puts "\s\sINTEREST PRICE RANGE OF #{interest_price}"
      end
    end

    def line_breaker_block(times_to_perform = 1)
      line_breaker(times_to_perform)
      yield
      line_breaker(times_to_perform)
    end

    def line_breaker(times_to_perform = 1)
      times_to_perform.times { puts '*' * 60 }
    end
  end
end

class GameInformation
  PRIMARY_URL = 'https://www.cdkeys.com'

  def initialize(url_id, interest_price)
    @page = parse_page(url_id)
    @interest_price = interest_price
  end

  def display_price_and_stock_information
    return out_of_stock_message if game_out_of_stock?
    return display_not_at_rate_message unless game_at_or_below_interest_price?

    display_success_message
  end

  private

  def parse_page(url_id)
    Nokogiri::HTML(URI.parse("#{PRIMARY_URL}/#{url_id}").open)
  end

  def availability_matcher
    #   Out of Stock  ||  In Stock
    /\w+\s+\w+\s+Stock|\w+\s+Stock/
  end

  def game_availability = @page.css('#product-details').first.children.text.match(availability_matcher)[0]

  def game_out_of_stock? = game_availability == 'Out of Stock'

  def game_name = @page.css('.product-title').first&.text&.strip

  def game_price
    @game_price ||= @page.css('.final-price.inline-block').first&.text&.strip
  end

  def game_at_or_below_interest_price? = game_price.gsub('$', '').to_f <= @interest_price.to_f

  def out_of_stock_message
    display_message('❌', "#{game_name} is not in stock")
  end

  def display_not_at_rate_message
    display_message('💰', "#{game_name} is available but at #{game_price}")
  end

  def display_success_message
    display_message('🎉', "#{game_name} is now #{game_price}!")
  end

  def display_message(emoji, message)
    newline_block do
      emoji_block(emoji) do
        puts message
      end
    end
  end

  def emoji_block(emoji)
    puts emoji * 30
    yield
    puts emoji * 30
  end

  def newline_block(times_to_perform = 1)
    newline(times_to_perform)
    yield
    newline(times_to_perform)
  end

  def newline(times_to_perform = 1)
    times_to_perform.times { puts "\n" }
  end
end

CDKeysScraper.execute
