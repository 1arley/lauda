# Lauda

Aplicação multi-tenant para gestão de avaliações, pacientes e emissão de laudos. Cada clínica cria sua conta e seus dados ficam isolados por tenant.

## Produção na VPS

O workflow em `.github/workflows/publish-image.yml` publica `ghcr.io/1arley/lauda:latest` a cada push na branch principal e imagens versionadas para tags `v*`. Depois da primeira publicação, deixe o pacote do GHCR público para a VPS baixar sem login.

O TLS fica com o Traefik da máquina, que já atende os outros sites e emite certificado Let's Encrypt para a rede externa `web`. Por isso o Compose não publica 80/443 nem traz um proxy próprio: ele entra na rede `web` e o Traefik roteia `APP_HOST` para o container. Em uma máquina sem Traefik, acrescente um proxy que aponte para a porta 80 do serviço `app`.

Na VPS, instale Docker Engine e o plugin Compose, crie a rede externa e aponte o DNS de `APP_HOST` para o servidor. Copie apenas `docker-compose.yml` e um `.env` preenchido para o diretório do projeto e rode:

```bash
docker network create web
docker compose up -d
```

O Compose sempre baixa a imagem mais recente, sobe o PostgreSQL, persiste banco e arquivos em volumes, prepara/migra o banco antes de iniciar o Rails e expõe o app apenas dentro da rede `web`. Não exponha a porta 5432 na internet.

Gere os segredos antes de preencher o `.env`:

```bash
openssl rand -hex 64 # SECRET_KEY_BASE
openssl rand -hex 24 # POSTGRES_PASSWORD
```

Configure também o domínio, um remetente e a credencial da Resend. O e-mail de confirmação de cadastro e o de recuperação de senha saem pela API HTTP da Resend (`RESEND_API_KEY` + `MAILER_SENDER`), não por SMTP: o egress das portas 25/465/587 está bloqueado no host da VPS, enquanto `api.resend.com:443` responde, e é assim que os demais apps da mesma VPS enviam. Crie a chave em resend.com/api-keys com acesso de envio; o remetente precisa pertencer a um domínio verificado no Resend. O primeiro usuário cria a clínica e vira seu administrador; não há conta demo nem senha compartilhada. Confirmação de e-mail fica ativa.

Os PDFs usam Solid Queue persistido no PostgreSQL e rodam no mesmo container Rails. Volumes Docker preservam os dados durante atualizações; mantenha backups externos do PostgreSQL e de `app_storage`.

## Desenvolvimento

```bash
docker compose -f docker-compose.dev.yml up -d db
docker compose -f docker-compose.dev.yml run --rm app bin/rails db:prepare
docker compose -f docker-compose.dev.yml up -d
```

## Instrumentos e normas

Não são criadas tabelas normativas falsas nem contas/pacientes de demonstração. Normas devem ser importadas de material oficial autorizado. Até que isso seja feito, os escores e compostos WISC-IV ainda não estão completos para uso clínico.

O catálogo é populado por `instruments:import`, que cria ou atualiza instrumento, versão e tabela normativa a partir de um JSON. O campo `source` (manual, edição e página) é obrigatório: norma sem procedência não entra, porque a plataforma promete guardar a versão da norma usada em cada cálculo. O formato está em `lib/tasks/instrument_import_template.json` e a importação é idempotente, então rodar de novo atualiza em vez de duplicar.

```bash
docker compose exec app bin/rails "instruments:import[/rails/caminho/instrumento.json]"
```

O arquivo precisa estar legível dentro do container; na VPS, copie para o diretório do projeto ou monte o volume. Confira o resultado com `conformidade:conferir`, que compara os escores calculados com um exemplo publicado do manual:

```bash
docker compose exec app bin/rails "conformidade:conferir[CODIGO,VERSAO,ARQUIVO_JSON]"
```
