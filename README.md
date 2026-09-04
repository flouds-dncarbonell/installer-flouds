# Installer Fzap

Instalador automatizado do **FZAP** — plataforma de automação WhatsApp desenvolvida pela [Flouds](https://flouds.com.br). O script prepara o servidor e instala tudo o que o FZAP precisa para funcionar com HTTPS.

---

## Pré-requisitos

- Servidor com **Ubuntu 20.04+**, Debian, RHEL, Rocky Linux, AlmaLinux, CentOS ou Fedora
- Acesso **root**
- Mínimo **2 vCPUs** e **2 GB RAM** (4 GB recomendado)
- Porta **80** e **443** liberadas no firewall
- Um domínio próprio. Na etapa de endereços o instalador oferece três caminhos:
  informar apenas o domínio-base (por exemplo `empresa.com.br`) e aceitar
  as sugestões `fzap.` e `painel.`; informar endereços já apontados para o
  servidor, com qualquer nome (por exemplo `app.empresa.com.br`); ou instalar
  localmente, sem domínio nenhum. Se o DNS ainda não estiver pronto, é possível
  instalar antes e criar os registros depois.

A instalação sem domínio dispensa as portas 80/443 e usa HTTP nas portas
8080/9000: veja [Instalação sem domínio](#instalação-sem-domínio).

Na primeira instalação, o próprio instalador configura:

- **Traefik**, responsável pelo acesso HTTPS e pelos certificados
- **Portainer**, painel técnico usado para instalar e administrar o FZAP
- A rede Docker compartilhada `proxy`

O usuário não precisa configurar esses componentes manualmente.

---

## Formas de instalação

| Ambiente | Método |
|---|---|
| VPS sem painel | Instalador automático via terminal |
| Coolify | Stack Docker Compose pronta |
| Easypanel | Template JSON one-click |

### VPS sem painel

Execute o comando abaixo no terminal do servidor como **root**:

```bash
curl -fsSL https://raw.githubusercontent.com/flouds-dncarbonell/installer-flouds/main/Setup | sudo bash
```

No menu, escolha **Instalar FZAP neste servidor**. A instalação tem cinco
etapas e pede apenas o domínio, o e-mail do certificado, o idioma e a licença:

1. **Verificar o servidor** — sistema, recursos, Docker, portas 80/443 e
   instalação anterior
2. **Endereços** — endereços sugeridos a partir do domínio-base, informados
   um a um (com conferência do DNS), ou instalação sem domínio
3. **Configurar o FZAP** — e-mail, idioma e licença, com confirmação final
4. **Instalar** — HTTPS, painel técnico, banco de dados e FZAP
5. **Verificar e concluir** — réplicas, certificado e endereço, antes de
   declarar sucesso

As configurações de infraestrutura ficam separadas em **Configurações
avançadas**, e as ações de suporte em **Manutenção e diagnóstico**.

#### Interrupções e reexecução

O instalador grava o progresso em `/root/dados_vps/estado_instalacao` somente
após verificar cada etapa. Ao ser executado de novo, ele oferece continuar de
onde parou; nenhuma rede, volume, stack ou token válido é recriado. Se o FZAP já
estiver instalado, a tela inicial mostra o endereço e o status em vez de um erro.

#### Se o Docker Swarm não iniciar

O instalador ativa o modo cluster do Docker (Swarm) antes de instalar qualquer
coisa. Quando isso falha, ele mostra a mensagem original do Docker — é ela que
diz o que houve. As duas causas mais comuns:

- **`could not choose an IP address to advertise`** — o servidor tem mais de um
  endereço e o Docker não escolhe sozinho. O instalador já tenta de novo com o
  IP da rota padrão e, por último, com `127.0.0.1`. Para resolver manualmente:

  ```bash
  docker swarm init --advertise-addr <IP-do-servidor>
  ```

- **Swarm em estado `pending` ou `locked`** — sobrou de uma tentativa anterior.
  Repetir o init não resolve; é preciso sair do cluster antes:

  ```bash
  docker swarm leave --force
  ```

  Depois execute o instalador novamente.

#### Detalhes técnicos

O caminho comum não mostra jargão. Os detalhes ficam em
`/root/dados_vps/instalacao.log` (as cinco últimas execuções) e podem ser
exibidos na tela com:

```bash
./SetupFlouds --verbose
```

Outras opções: `--infra-only` instala apenas Traefik e Portainer, `--local`
instala sem domínio com detecção automática, `--ip` força o IP público e
`NO_COLOR=1` desativa as cores sem perder nenhuma informação.

#### Instalação sem domínio

Para instalar o FZAP sem domínio, escolha a opção correspondente na etapa de
endereços ou execute o
instalador com `--local`:

```bash
./SetupFlouds --local
```

Se a VPS recebe o IP público por NAT e for detectada como ambiente local, use
`./SetupFlouds --ip` ou escolha **usar o IP público mesmo com NAT** no menu.

Nesse modo o FZAP e o painel técnico publicam portas direto no host, sem
Traefik e sem HTTPS. Numa VPS com IP público diretamente atribuído, o
instalador detecta o IP e o usa como endereço:

| Serviço | Endereço |
|---|---|
| FZAP | `http://IP-DA-VPS:8080` |
| Painel técnico (Portainer) | `http://IP-DA-VPS:9000` |

O instalador pula a verificação de DNS e a emissão do certificado. Em uma VPS,
ele libera as portas **8080** e **9000** no UFW quando este estiver ativo. Talvez
também seja necessário liberar essas portas no firewall do provedor.

Quando o ambiente parece local (WSL, ausência de IP público alcançável ou IP
privado atrás de NAT), o endereço continua sendo `http://localhost:8080`, com o
painel em `http://localhost:9000`.

Uma instalação sem domínio **não é recomendada para produção**. O tráfego e
o painel ficam sem HTTPS, e integrações que exigem uma URL HTTPS podem não
funcionar. Use senhas fortes e restrinja a porta 9000 no firewall do provedor.

### Coolify

1. Crie um recurso **Docker Compose Empty**.
2. Cole o conteúdo de
   [`deploy/coolify/docker-compose.yml`](./deploy/coolify/docker-compose.yml).
3. No serviço `fzap`, configure o domínio com a porta interna `8080`, por
   exemplo: `https://fzap.seudominio.com:8080`.
4. Preencha a licença e as configurações opcionais desejadas.
5. Salve e faça o deploy.

O Coolify administra o domínio, certificado HTTPS, rede interna, volumes,
senha do PostgreSQL e token administrativo. Consulte o
[`guia completo do Coolify`](./deploy/coolify/README.md).

### Easypanel

Na VPS onde o Easypanel está instalado, execute:

```bash
curl -fsSL https://raw.githubusercontent.com/flouds-dncarbonell/installer-flouds/main/SetupEasypanel | bash
```

O comando cria `/tmp/fzap-easypanel.json` com senha do banco e token
administrativo exclusivos. Para instalar:

1. Execute `cat /tmp/fzap-easypanel.json` e copie todo o conteúdo.
2. No Easypanel, abra **Templates** e escolha **Import JSON** ou
   **Create from JSON**.
3. Cole o conteúdo, defina o nome do projeto e clique em **Create**.
4. Abra o serviço `fzap`, adicione seu domínio e marque-o como principal.
5. Confirme que a porta de proxy é `8080` e faça o deploy.

O template cria o FZAP, PostgreSQL 17 com pgvector, volumes persistentes, senha
do banco e `ADMIN_TOKEN` automaticamente. O JSON gerado contém credenciais e
deve ser apagado depois da importação. Consulte o
[`guia completo do Easypanel`](./deploy/easypanel/README.md).

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

A stack do Fzap usa Docker Swarm com Traefik para SSL automático — exceto na
instalação sem domínio, que dispensa o Traefik e publica as portas direto no host. As
principais variáveis de ambiente configuradas durante a instalação:

| Variável | Descrição |
|---|---|
| `PUBLIC_BASE_URL` | URL completa onde o Fzap está acessível (`http://IP-DA-VPS:8080` sem domínio, ou localhost em ambiente local) |
| `FZAP_LANGUAGE` | Idioma: `pt-BR`, `en-US`, `es-LATAM` |
| `ADMIN_TOKEN` | Token de autenticação da API |
| `FLOUDS_LICENCE_KEY` | Chave de licença (vazio = versão free) |
| `DB_HOST` / `DB_NAME` / `DB_USER` / `DB_PASSWORD` | Conexão PostgreSQL |
| `SESSION_DEVICE_NAME` | Nome exibido no celular ao conectar |

Também estão disponíveis configurações opcionais para proxy global, armazenamento
S3 compartilhado, banco global do Chatwoot, transcrição de áudio, limites e
timeouts de mídia, extensão Passkey e filas de falha (DLQ) do RabbitMQ. O
instalador deixa essas opções comentadas na stack gerada para configuração pelo
Portainer quando necessário.

O arquivo de referência da stack completa está em [`stack-fzap.md`](./stack-fzap.md).

---

## Volumes criados

| Volume | Uso |
|---|---|
| `fzap_dbdata` | Dados persistentes do PostgreSQL 17 (pgvector) |
| `fzap_app_dbdata` | Dados locais persistentes da aplicação |
| `fzap_files` | Arquivos de mídia |
| `fzap_logos` | Logos e assets públicos |

---

## Referências

- [Flouds](https://flouds.com.br) — empresa desenvolvedora do Fzap

---

## Créditos

O padrão de estrutura deste instalador foi inspirado no [SetupOrion](https://github.com/oriondesign2015/SetupOrion), projeto da comunidade OrionDesign. Este projeto é mantido pela Flouds e não é afiliado ou endossado pelo SetupOrion.
