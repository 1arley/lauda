# Lauda

Aplicação multi-tenant para gestão de avaliações, pacientes e emissão de laudos. Cada clínica cria sua conta e seus dados ficam isolados por tenant.

## Produção na VPS

O workflow em `.github/workflows/publish-image.yml` publica `ghcr.io/1arley/lauda:latest` a cada push na branch principal e imagens versionadas para tags `v*`. Depois da primeira publicação, deixe o pacote do GHCR público para a VPS baixar sem login.

Na VPS, instale Docker Engine e o plugin Compose, aponte o DNS de `APP_HOST` para o servidor e libere as portas 80 e 443. Copie apenas `docker-compose.yml` e um `.env` preenchido e rode:

```bash
docker compose up -d
```

O Compose sempre baixa a imagem mais recente, sobe PostgreSQL e Caddy, emite TLS automaticamente, persiste banco e arquivos em volumes e prepara/migra o banco antes de iniciar Rails. Não exponha a porta 5432 na internet.

Gere os segredos antes de preencher o `.env`:

```bash
openssl rand -hex 64 # SECRET_KEY_BASE
openssl rand -hex 24 # POSTGRES_PASSWORD
```

Configure também o domínio, um remetente e as credenciais SMTP. SMTP é necessário para confirmar cadastros e recuperar senhas. O primeiro usuário cria a clínica e vira seu administrador; não há conta demo nem senha compartilhada. Confirmação de e-mail fica ativa.

Os PDFs usam Solid Queue persistido no PostgreSQL e rodam no mesmo container Rails. Volumes Docker preservam os dados durante atualizações; mantenha backups externos do PostgreSQL e de `app_storage`.

## Desenvolvimento

```bash
docker compose -f docker-compose.dev.yml up -d db
docker compose -f docker-compose.dev.yml run --rm app bin/rails db:prepare
docker compose -f docker-compose.dev.yml up -d
```

## Instrumentos e normas

Não são criadas tabelas normativas falsas nem contas/pacientes de demonstração. Normas devem ser importadas de material oficial autorizado. Até que isso seja feito, os escores e compostos WISC-IV ainda não estão completos para uso clínico.
