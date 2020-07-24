class ClubController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :cors_set_access_control_headers

  def receive_form
    if Rails.env.development?
      Stripe.api_key = ENV["STRIPE_TEST_SECRET_KEY"]
    else
      Stripe.api_key = ENV["STRIPE_LIVE_SECRET_KEY"]
    end

    headers['Access-Control-Allow-Origin'] = '*'
    puts params

    # ClubMailer.form_data(params).deliver

    customer = ShopifyAPI::Customer.find(:first, params: {email: params["email"]})
    full_name = params["first_last_name"].split(' ', 2)

    unless customer
      customer = ShopifyAPI::Customer.new

      address = {
        address1: params["shipping_street_address"],
        city: params["shipping_city"],
        province: params["shipping_state"],
        phone: params["phone"],
        zip: params["shipping_zip_code"],
        last_name: full_name.last,
        first_name: full_name.first,
        country: "united states"
      }

      customer.email = params["email"]
      customer.first_name = full_name.first
      customer.last_name = full_name.last
      customer.addresses = [address]

      customer.save
    end

    order = ShopifyAPI::Order.new
    order.email = params["email"]
    order.send_receipt = true
    order.line_items = [
      variant_id: 32659698384999,
      quantity: 1
    ]

    order.test = Rails.env.development?

    # order.save

    begin
      address2 = params["billing_apartment_unit"] ||= ""
      expiration = params["expiration_date"].split('/')
      stripe_token = Stripe::Token.create(
        :card => {
          :number => params["credit_card_number"],
          :exp_month => expiration[0],
          :exp_year => expiration[1],
          :name => params["cardholder_name"],
          :address_line1 => params["billing_street_address"],
          :address_line2 => address2,
          :address_city => params["billing_city"],
          :address_state => params["billing_state"],
          :address_zip => params["billing_zip_code"]
        },
      )

      stripe_customer = Stripe::Customer.create(
        :description => "Customer: #{full_name.first} #{full_name.last}",
        :source => stripe_token,
        :email => params["email"]
      )
    rescue => e
      puts e.message
    end

    render json: params
  end

  private

    def set_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Request-Method'] = '*'
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, PATCH, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end
end
