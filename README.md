# Lauda

Plataforma SaaS multi-tenant para avaliação psicológica/neuropsicológica: cadastro de pacientes, aplicação de instrumentos, cálculo de escores com tabelas normativas e emissão de laudos em PDF.

## Stack

- Ruby on Rails 8.1 + PostgreSQL + Redis (Sidekiq/Solid Queue)
- Devise (auth), Pundit + ActsAsTenant (autorização e isolamento por tenant)
- Tailwind CSS, Turbo/Stimulus, Prawn (PDF)
- Docker / Kamal para deploy

## Rodando

```bash
cp .env.example .env
docker compose up -d
bin/rails db:setup
bin/dev
```

Testes: `bin/rspec` (ou `bin/rails test`).

## Estrutura

- `app/models` — tenant, patient, assessment, instrument, score, report
- `app/controllers` — fluxo avaliação → instrumento → laudo, além de `admin/`
- `app/services/pdf` — geração dos laudos
- `db/schema.rb` — modelo de dados (UUID por padrão)
