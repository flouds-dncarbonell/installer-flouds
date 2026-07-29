# Instalar o FZAP no Easypanel

Você não precisa criar banco, volumes ou variáveis manualmente. O instalador
gera um template pronto que cria:

- um serviço PostgreSQL 17 com pgvector;
- um serviço FZAP publicado na porta interna `8080`;
- senha do banco e `ADMIN_TOKEN` aleatórios;
- três volumes persistentes da aplicação;
- todas as variáveis opcionais da stack.

## Antes de começar

- Tenha o Easypanel funcionando em uma VPS.
- Aponte o domínio do FZAP para o IP dessa VPS.
- Acesse a VPS por SSH.

## 1. Gere o template

Execute este único comando na VPS:

```bash
curl -fsSL https://raw.githubusercontent.com/flouds-dncarbonell/installer-flouds/main/SetupEasypanel | bash
```

Ao terminar, você verá a mensagem `Template criado com sucesso`. O arquivo
ficará em `/tmp/fzap-easypanel.json`.

## 2. Copie o JSON

No terminal, execute:

```bash
cat /tmp/fzap-easypanel.json
```

Copie desde a primeira `{` até a última `}`.

## 3. Importe no Easypanel

1. Abra **Templates** no Easypanel.
2. Clique em **Import JSON**, **Create from JSON** ou **Custom Template**.
3. Cole o JSON copiado.
4. Informe um nome para o projeto, por exemplo `fzap`.
5. Clique em **Create**.

O painel criará dois serviços:

| Serviço | Função |
|---|---|
| `fzap` | Aplicação e painel do FZAP |
| `fzap-db` | PostgreSQL com pgvector |

## 4. Configure o domínio

1. Abra o serviço `fzap`.
2. Entre em **Domains & Proxy**.
3. Adicione o domínio do FZAP.
4. Marque esse domínio como principal.
5. Confirme que **Proxy Port** está como `8080`.
6. Salve e faça o deploy.

O `PUBLIC_BASE_URL` usa `https://$(PRIMARY_DOMAIN)` e acompanha o domínio
marcado como principal no Easypanel.

## 5. Acesse o FZAP

Quando os dois serviços estiverem ativos, abra o domínio configurado. O token
administrativo está em:

**Serviço `fzap` → Environment → `ADMIN_TOKEN`**

## Segurança

O JSON contém a senha do banco e o token administrativo. Depois que a
importação funcionar, apague-o:

```bash
rm -f /tmp/fzap-easypanel.json
```

Não envie esse arquivo por e-mail, mensagem ou commit no Git.

## Configurações opcionais

Chatwoot, S3, transcrição, Meta Embedded Signup, RabbitMQ, Sentry e demais
opções ficam disponíveis em **Serviço `fzap` → Environment**.

## Instalação manual para desenvolvedores

Quem já clonou este repositório também pode gerar o JSON diretamente:

```bash
node deploy/easypanel/generate-template.mjs > /tmp/fzap-easypanel.json
```

## Fonte do template oficial

Os arquivos `meta.yaml` e `index.ts` seguem o formato do repositório oficial de
templates do Easypanel e podem ser testados no playground ou submetidos à
galeria.
