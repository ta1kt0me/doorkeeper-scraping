require 'dotenv'
require 'byebug'
require 'open-uri'
require 'oga'

Dotenv.load

class Scraping
  Participant = Struct.new(:id, :name, :email, :coupon, :payment)
  Ticket      = Struct.new(:type, :payment)

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
    byebug
    ids      = html.xpath('//div[@id="attending"]//td[@class="sc"]').map { |e| e.text.strip }
    names    = html.xpath('//div[@id="attending"]//div[@class="user-name"]').map { |e| e.text.strip }
    emails   = html.xpath('//div[@id="attending"]//div[@class="user-email"]').map { |e| e.text.strip }
    coupons  = html.xpath('//div[@class="span12"]/table/tr[@role="row"]').map(&:text)
    payments = parse_ticket html.xpath('//div[@id="attending"]//td[@class="no-ellipsis smaller"]').map { |e| e.text.strip }

    ids.each_with_index { |id, i| Participant.new id, names[i], emails[i], coupons[i], payments[i] }
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

  def parse_ticket(list)
    list.each do |e|
      type, payment = e.gsub(/\(/, ':').delete(')').split(/:/)
      Ticket.new type, payment
    end
  end
end

s = Scraping.new
# s.promote_codes
s.participants
