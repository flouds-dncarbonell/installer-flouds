# Installer Fzap

Instalador automatizado do **Fzap** — plataforma de automação WhatsApp desenvolvida pela [Flouds](https://flouds.com.br). O script prepara o ambiente, instala o Docker, inicializa o Docker Swarm e sobe a stack completa do Fzap no seu servidor.

---

## Pré-requisitos

- Servidor com **Ubuntu 20.04+** (ou Debian compatível)
- Acesso **root**
- Mínimo **2 vCPUs** e **2 GB RAM** (4 GB recomendado)
- Porta **80** e **443** liberadas no firewall
- Um **domínio** apontando para o IP do servidor
- **Traefik** já em execução na rede `FloudsNet` (com o resolver `letsencryptresolver`)

> Caso precise instalar o Traefik e criar a rede, use o SetupFlouds como ponto de partida.

---

## Como instalar

Execute o comando abaixo no terminal do servidor como **root**:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/dncarbonell/installer-fzap/main/Setup)
```

O script irá:

1. Atualizar o sistema (`apt update` / `apt upgrade`)
2. Instalar dependências: `sudo`, `jq`, `git`, `curl`, `apache2-utils`
3. Instalar o **Docker** (caso não esteja presente)
4. Inicializar o **Docker Swarm** (caso não esteja ativo)
5. Baixar e executar o instalador principal `SetupFlouds`

---

## O que é o Fzap

O Fzap é uma aplicação que roda em container Docker e oferece:

- Conexão com **WhatsApp** (sessões via QR Code ou Cloud API/Meta)
- Integração com **Chatwoot**
- Webhooks em formato JSON
- Suporte a **WhatsApp Cloud API** (Meta Embedded Signup)
- Mensageria via **RabbitMQ** (opcional)
- Rastreamento de erros via **Sentry** (opcional)
- Sistema de licença (versão free + assinatura)

---

## Stack

A stack do Fzap usa Docker Swarm com Traefik para SSL automático. As principais variáveis de ambiente configuradas durante a instalação:

| Variável | Descrição |
|---|---|
| `PUBLIC_BASE_URL` | URL completa onde o Fzap está acessível |
| `FZAP_LANGUAGE` | Idioma: `pt-BR`, `en-US`, `es-LATAM` |
| `ADMIN_TOKEN` | Token de autenticação da API |
| `FLOUDS_LICENCE_KEY` | Chave de licença (vazio = versão free) |
| `DB_HOST` / `DB_NAME` / `DB_USER` / `DB_PASSWORD` | Conexão PostgreSQL |
| `SESSION_DEVICE_NAME` | Nome exibido no celular ao conectar |

O arquivo de referência da stack completa está em [`stack-fzap.md`](./stack-fzap.md).

---

## Volumes criados

| Volume | Uso |
|---|---|
| `fzap_dbdata` | Banco de dados SQLite interno |
| `fzap_files` | Arquivos de mídia |
| `fzap_logos` | Logos e assets públicos |

---

## Referências

- [Flouds](https://flouds.com.br) — empresa desenvolvedora do Fzap

---

> O padrão de estrutura deste instalador foi inspirado no [SetupOrion](https://github.com/oriondesign2015/SetupOrion).
