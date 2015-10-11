require 'dotenv'
require 'byebug'
require 'open-uri'
require 'oga'

Dotenv.load

class Scraping
  def initialize
    @remember_user_token = ENV['REMEMBER_USER_TOKEN']
    @group = ENV['GROUP_NAME']
    @event = ENV['EVENT_ID']
  end

  def promote_codes
    uri = URI("https://manage.doorkeeper.jp/groups/#{@group}/events/#{@event}/promo_codes")
    html = read_html uri
    html.xpath('//div[@class="span9"]/table/tr/td[1]').map(&:text)
  end

  def participants
    uri = URI("https://manage.doorkeeper.jp/groups/#{@group}/events/#{@event}/tickets")
    html = read_html uri
    # TODO: fix correct xpath
    html.xpath('//div[@class="span12"]/table/tr[@role="row"]').map(&:text)
  end

  private

  def req_cookie
    cookie = { remember_user_token: @remember_user_token }
    cookie.map { |x| x.join('=') }.join(';')
  end

  def read_html(uri)
    open(uri, { 'Cookie' => req_cookie }) do |f|
      Oga.parse_html f.read
    end
  end
end

s = Scraping.new
s.promote_codes
s.participants
