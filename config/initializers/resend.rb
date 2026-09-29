# Chave lida no momento do envio, e nao no boot: dev e test sobem sem a
# variavel presente e so quebram se algo tentar de fato entregar um e-mail.
Resend.api_key = -> { ENV.fetch('RESEND_API_KEY', nil) }
