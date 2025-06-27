# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'date'
require 'pry'

class CDKeysScraper
  LINK_IDENTIFIERS = {
    '30' => %w[
      god-of-war-ragnarok-pc-steam-na
      the-legend-of-heroes-trails-through-daybreak-pc-steam
    ],
    '25' => %w[
      horizon-forbidden-west-complete-edition-pc-steam
      clair-obscur-expedition-33-pc-steam
      warhammer-40-000-space-marine-2-pc-steam
      the-hundred-line-last-defense-academy-pc-steam
    ],
    '20' => %w[
        outriders-complete-edition-pc-steam
    ]
  }.freeze

  class << self
    def execute
      LINK_IDENTIFIERS.each do |interest_price, url_ids|
        display_price_header(interest_price)

        url_ids.each { |url_id| GameInformation.new(url_id, interest_price).display_price_and_stock_information }
      end
    end

    private

    def display_price_header(interest_price)
      puts "\n"
      line_breaker_block(2) do
        puts ("\s" * 15) + "INTEREST PRICE RANGE OF #{interest_price}"
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
  PRIMARY_URL = 'https://www.cdkeys.com/'

  def initialize(url_id, interest_price)
    @page = parse_page(url_id)
    @interest_price = interest_price
  end

  def display_price_and_stock_information
    return out_of_stock_message if game_out_of_stock?

    game_at_or_below_interest_price? ? display_success_message : display_not_at_rate_message
  end

  private

  def parse_page(url_id)
    Nokogiri::HTML(URI.parse("#{PRIMARY_URL}#{url_id}").open)
  end

  def availability_matcher
    #   Out of Stock  ||  In Stock
    /[\w+\s]+Stock/
  end

  def game_availability = @page.css('#product-details').first&.children&.text&.match(availability_matcher)&.[](0)&.strip

  def game_out_of_stock? = game_availability == 'Out of Stock'

  def game_name = @page.css('.product-title').first&.text&.strip

  def game_price
    @game_price ||= @page.css('.final-price.inline-block').first&.text&.strip
  end

  def discount_coupon_amount
    cap_amount = 2.75
    ten_percecent_discount_amount = game_price_to_float * 0.1

    if ten_percecent_discount_amount < cap_amount
      game_price_to_float - ten_percecent_discount_amount
    else
      game_price_to_float - cap_amount
    end.round(2)
  end

  def game_price_to_float
    @game_price_to_float ||= game_price.gsub('$', '').to_f
  end

  def game_price_with_discount
    @game_price_with_discount ||= if coupon_discount?
                                    discount_coupon_amount
                                  else
                                    game_price
                                  end
  end

  def coupon_discount?
    return @coupon_discount if defined?(@coupon_discount)

    coupon_end_date = DateTime.new(2025, 12, 1)

    @coupon_discount ||= coupon_end_date > DateTime.now
  end

  def with_discount_statement
    "\swith discount applied" if coupon_discount?
  end

  def game_at_or_below_interest_price? = game_price_with_discount <= @interest_price.to_f

  def out_of_stock_message = display_message('❌', "#{game_name} is not in stock.")

  def display_not_at_rate_message
     display_message('💰', "#{game_name} is available but at #{game_price_with_discount}#{with_discount_statement}.")
  end

  def display_success_message
    display_message('🎉', "#{game_name} is now #{game_price_with_discount}#{with_discount_statement}!")
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

  def newline_block
    puts "\n"
    yield
    puts "\n"
  end
end

CDKeysScraper.execute
