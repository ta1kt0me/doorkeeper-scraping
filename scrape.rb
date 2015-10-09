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
    html = open(uri, { 'Cookie' => req_cookie }) do |f|
      Oga.parse_html f.read
    end
    html.xpath('//div[@class="span9"]/table/tr/td[1]').map { |elem| elem.text }
  end

  def participants
    uri = URI("https://manage.doorkeeper.jp/groups/#{@group}/events/#{@event}/tickets")
    html = open(uri, { 'Cookie' => req_cookie }) do |f|
      Oga.parse_html f.read
    end
    # TODO: fix correct xpath
    html.xpath('//div[@class="span12"]/table/tr[@role="row"]').map(&:text)
  end

  def req_cookie
    cookie = { remember_user_token: @remember_user_token }
    cookie.map { |x| x.join('=') }.join(';')
  end
end

s = Scraping.new
s.promote_codes
s.participants
