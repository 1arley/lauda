Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      time: event.time,
      user_id: event.payload[:current_user_id],
      tenant_id: event.payload[:tenant_id],
      request_id: event.payload[:request_id]
    }
  end
end
