require 'net/http'
require 'cgi'
require 'dotenv'
Dotenv.load

class Scraping
  def initialize
    @remember_user_token = ENV['REMEMBER_USER_TOKEN']
    @group = ENV['GROUP_NAME']
    @event = ENV['EVENT_ID']
  end

  def promote_codes
    uri = URI("https://manage.doorkeeper.jp/groups/#{@group}/events/#{@event}/promo_codes")

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new uri.request_uri
    cookie = CGI::Cookie.new 'remember_user_token', @remember_user_token
    request['Cookie'] = cookie.to_s
    res = http.request request
    print res.body
  end
end

s = Scraping.new
s.promote_codes
