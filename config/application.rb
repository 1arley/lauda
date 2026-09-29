require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module LaudosSaas
  class Application < Rails::Application
    config.load_defaults 8.1
    config.i18n.default_locale = :'pt-BR'

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       request_specs: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.active_job.queue_adapter = :solid_queue
    # test é single-db (config/database.yml), então não há conexão :queue separada lá.
    config.solid_queue.connects_to = { database: { writing: :queue } } unless Rails.env.test?
  end
end
