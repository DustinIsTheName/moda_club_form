require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ModaClubForm
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    ShopifyAPI::Base.site = "https://#{ENV["API_KEY"]}:#{ENV["PASSWORD"]}@moda-lookbook.myshopify.com/admin"
    ShopifyAPI::Base.api_version = '2020-04'
  end
end
