#!/bin/bash
## // ## // ## // ## // ## // ## // ## // ## // ## // ## // ## // ## // ## //
##                      FLOUDS INSTALLER — LIB COMUM                       ##
##  Funções reutilizáveis carregadas pelos comandos isolados em cmd/.      ##
##  Uso nos scripts cmd/<nome>:                                            ##
##    source <(curl -fsSL "$REPO_RAW/lib/common.sh")                       ##
## // ## // ## // ## // ## // ## // ## // ## // ## // ## // ## // ## // ## //

## Base do repositório (sobrescrevível por variável de ambiente)
REPO_RAW="${REPO_RAW:-https://raw.githubusercontent.com/flouds-dncarbonell/installer-flouds/main}"

## Cores
amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
bege="\e[93m"
vermelho="\e[91m"
reset="\e[0m"

## Diretório de dados (mesmo layout do SetupFlouds)
home_directory="$HOME"
dados_vps="${home_directory}/dados_vps/dados_vps"
dados_portainer_file="${home_directory}/dados_vps/dados_portainer"

## Garante leitura interativa quando carregado via pipe (curl | bash)
## Não usamos exec </dev/tty porque isso quebra a leitura do resto do pipe
## em curl | bash. Em vez disso, cada read usa /dev/tty diretamente.
read_rp() {
    read -rp "$1" "$2" </dev/tty
}
read_rs() {
    read -rs -p "$1" "$2" </dev/tty
}
read_r() {
    read -r "$1" </dev/tty
}

## --- Mensagens ----------------------------------------------------------
msg_info()  { echo -e "$amarelo$*$reset"; }
msg_ok()    { echo -e "$verde  ✔ $*$reset"; }
msg_erro()  { echo -e "$vermelho  ✖ $*$reset"; }

## --- Pré-requisitos -----------------------------------------------------
exigir_root() {
    if [ "$(id -u)" -ne 0 ]; then
        msg_erro "Este comando precisa ser executado como root (use sudo)."
        exit 1
    fi
}

exigir_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        msg_erro "Docker não encontrado. Rode o instalador base (Setup) primeiro."
        exit 1
    fi
}

## --- Helpers ------------------------------------------------------------
## Gera string aleatória segura
gerar_token() {
    local tamanho="${1:-32}"
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$tamanho"
}

## Oculta senha para exibição
esconder_senha() {
    local senha="$1"
    local visivel=4
    local tamanho=${#senha}
    if [ "$tamanho" -le "$visivel" ]; then
        SENHAOCULTA="****"
    else
        SENHAOCULTA="${senha:0:$visivel}$(printf '*%.0s' $(seq 1 $((tamanho - visivel))))"
    fi
}

## Valida senha (mínimo de caracteres)
validar_senha() {
    local senha="$1"
    local min="${2:-12}"
    if [ ${#senha} -lt "$min" ]; then
        msg_erro "Senha muito curta. Mínimo $min caracteres."
        return 1
    fi
    return 0
}

## Normaliza domínio (remove protocolo/porta/path)
normalizar_dominio() {
    local dominio="$1"
    dominio="${dominio#http://}"
    dominio="${dominio#https://}"
    dominio="${dominio%%/*}"
    dominio="${dominio%%:*}"
    echo "$dominio"
}

## IP público da VPS
obter_ip_publico() {
    curl -fsS4 --max-time 10 https://ifconfig.me 2>/dev/null \
        || curl -fsS4 --max-time 10 https://api.ipify.org 2>/dev/null
}

## Verifica se uma stack já existe no Swarm (0 = existe)
stack_existe() {
    local nome_stack="$1"
    docker stack ls --format "{{.Name}}" 2>/dev/null | grep -q "^${nome_stack}$"
}

## Carrega dados gravados pelo instalador base
carregar_dados() {
    if [ -f "$dados_vps" ]; then
        nome_servidor=$(grep "Nome do Servidor:" "$dados_vps" | awk -F': ' '{print $2}')
        nome_rede_interna=$(grep "Rede interna:" "$dados_vps" | awk -F': ' '{print $2}')
    fi
}
