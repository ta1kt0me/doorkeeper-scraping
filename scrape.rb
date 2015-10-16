require 'dotenv'
require 'byebug'
require 'open-uri'
require 'oga'

Dotenv.load

class Scraping
  Participant = Struct.new(:id, :name, :email, :coupon, :type, :payment)
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
    ids      = html.xpath('//div[@id="attending"]//td[@class="sc"]').map { |e| e.text.strip }
    names    = html.xpath('//div[@id="attending"]//div[@class="user-name"]').map { |e| e.text.strip }
    emails   = html.xpath('//div[@id="attending"]//div[@class="user-email"]').map { |e| e.text.strip }
    tr_ids   = html.xpath('//div[@id="attending"]//tbody//tr').attribute('id')
    coupons  = tr_ids.reduce([]) do |list, id|
      title = html.xpath("//tr[@id='#{id}']//span[@class='popupHelp']").attribute('title')
      list << (title.empty? ? nil : title.first.value.split(': ').last)
      list
    end
    payments = parse_ticket(html.xpath('//div[@id="attending"]//td[@class="no-ellipsis smaller"]').map { |e| e.text.strip })
    participants = ids.each_with_index.map { |id, i| Participant.new id, names[i], emails[i], coupons[i], payments[i][:type], payments[i][:payment] }
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
    list.map do |e|
      type, payment = e.gsub(/\(/, ':').delete(')').split(/:/).map(&:strip)
      Ticket.new type, payment
    end
  end
end

s = Scraping.new
# s.promote_codes
s.participants
# s.participants.map { |e| e.coupon.nil? ? nil : e }.compact.group_by(&:coupon).reduce({}) { |h, e| h[e.key] = e.value.count }
