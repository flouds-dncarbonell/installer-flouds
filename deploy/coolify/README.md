# Teste do FZAP no Coolify

Esta stack deve ser criada como um único recurso do tipo **Docker Compose
Empty**. O Coolify administra a rede interna, o domínio, o proxy HTTPS e os
volumes.

## Instalação

1. No projeto desejado, escolha **New Resource**.
2. Selecione **Docker Compose Empty**.
3. Cole o conteúdo de `docker-compose.yml` no editor.
4. Salve o Compose.
5. Em **Environment Variables**, confira:
   - `FZAP_LANGUAGE`: `pt-BR`, `en-US` ou `es-LATAM`;
   - `FLOUDS_LICENCE_KEY`: opcional;
   - `SESSION_DEVICE_NAME`: nome exibido no dispositivo.
6. Em **Domains**, confirme o domínio do serviço `fzap` e a porta interna
   `8080`.
7. Clique em **Deploy**.

O Coolify gera automaticamente:

- `SERVICE_URL_FZAP_8080`, que informa ao proxy a porta interna do FZAP;
- `SERVICE_URL_FZAP`, usada como `PUBLIC_BASE_URL` sem expor a porta interna;
- `SERVICE_PASSWORD_FZAP`, usada como `ADMIN_TOKEN`;
- `SERVICE_PASSWORD_POSTGRES`, compartilhada pelo FZAP e PostgreSQL.

O valor do token administrativo pode ser consultado nas variáveis do recurso
após a criação.

## Variáveis opcionais

O Compose também expõe no Coolify todas as opções disponíveis na stack do
instalador:

- integração e banco global do Chatwoot;
- proxy global e extensão Passkey;
- licença vitalícia;
- qualidade, tamanho e timeouts de mídia;
- armazenamento S3 global;
- transcrição de áudio;
- WhatsApp Cloud API/Meta Embedded Signup;
- RabbitMQ e DLQ;
- Sentry.

Variáveis vazias ou com o recurso correspondente desabilitado podem permanecer
com seus valores padrão. Credenciais opcionais devem ser marcadas como secret
na interface do Coolify.

## Persistência

Não remova os volumes ao recriar ou atualizar os containers:

- `fzap_dbdata`;
- `fzap_app_dbdata`;
- `fzap_files`;
- `fzap_logos`.

O PostgreSQL não publica porta no host. O FZAP acessa o banco pela rede interna
usando `DB_HOST=postgres`.
