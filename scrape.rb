require 'dotenv'
require 'byebug'
require 'open-uri'

Dotenv.load

class Scraping
  def initialize
    @remember_user_token = ENV['REMEMBER_USER_TOKEN']
    @group = ENV['GROUP_NAME']
    @event = ENV['EVENT_ID']
  end

  def promote_codes
    uri = URI("https://manage.doorkeeper.jp/groups/#{@group}/events/#{@event}/promo_codes")
    cookie = { remember_user_token: @remember_user_token }
    cookie_str = cookie.map { |x| x.join('=') }.join(';')
    open(uri, { 'Cookie' => cookie_str }) { |f| print f.read }
  end
end

s = Scraping.new
s.promote_codes
