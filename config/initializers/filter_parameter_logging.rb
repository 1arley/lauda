Rails.application.config.filter_parameters += %i[
  password password_confirmation ssn credit_card
]
