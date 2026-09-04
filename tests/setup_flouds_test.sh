#!/usr/bin/env bash

set -uo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
setup_file="$repo_dir/SetupFlouds"

load_setup() {
    source <(sed '/## Verifica root/,$d' "$setup_file")
}

test_state_and_menu() (
    set -e
    load_setup

    local test_dir
    test_dir=$(mktemp -d)
    estado_file="$test_dir/estado"
    log_file="$test_dir/log"
    fluxo_instalacao="etapas"
    modo_local=true
    url_fzap="198.51.100.10"
    url_portainer="198.51.100.10"
    nome_rede_interna="proxy"

    estado_gravar "infra_pronta" "aguardando_fzap"

    fluxo_instalacao=""
    modo_local=false
    url_fzap=""
    estado_restaurar_dados

    [ "$fluxo_instalacao" = "etapas" ]
    [ "$modo_local" = true ]
    [ "$url_fzap" = "198.51.100.10" ]
    [ "$(estado_ler "Situacao")" = "aguardando_fzap" ]

    clear() { :; }
    menu=$(menu_instalador)
    printf '%s' "$menu" | rg -q "Instalacao completa|Instalação completa"
    printf '%s' "$menu" | rg -q "FZAP aguardando"
)

test_environment_modes() (
    set -e
    load_setup

    modo_local=true
    parece_ambiente_local() { return 1; }
    ip_publico() { echo "198.51.100.20"; }
    configurar_enderecos_locais
    [ "$(url_fzap_completa)" = "http://198.51.100.20:8080" ]

    parece_ambiente_local() { return 0; }
    forcar_ip_publico=false
    configurar_enderecos_locais
    [ "$(url_fzap_completa)" = "http://localhost:8080" ]

    forcar_ip_publico=true
    configurar_enderecos_locais
    [ "$(url_fzap_completa)" = "http://198.51.100.20:8080" ]
)

test_staged_pause() (
    set -e
    load_setup

    events=""
    current=""
    situation=""
    nome_rede_interna=""

    dados() { :; }
    validar_rede_docker() { return 0; }
    rotacionar_log() { :; }
    log_tecnico() { :; }
    stack_saudavel() { return 1; }
    tela_retomar() { return 0; }
    etapa1_verificar_servidor() { events="$events verify"; current="verificado_servidor"; }
    etapa2_enderecos() { events="$events addresses"; current="dns_ok"; url_fzap="app.test"; }
    etapa3_configurar() { events="$events config"; current="dados_confirmados"; }
    etapa4_instalar_so_infraestrutura() { events="$events infra"; return 0; }
    decidir_depois_da_infraestrutura() { events="$events pause"; return 1; }
    etapa4_instalar_so_fzap() { events="$events app"; return 0; }
    etapa4_instalar() { events="$events complete"; return 0; }
    estado_gravar() { current="$1"; situation="${2:-em_andamento}"; }
    estado_ler() {
        case "$1" in
            "Situacao") echo "$situation" ;;
            "Etapa concluida") echo "$current" ;;
        esac
    }
    estado_alcancou() { [ "$1" = "infra_pronta" ] && [ "$current" = "infra_pronta" ]; }
    tela_ja_instalado() { events="$events already"; }
    tratar_falha() { return 1; }

    jornada_instalar_fzap "etapas"

    [ "$events" = " verify addresses config infra pause" ]
    [ "$current" = "infra_pronta" ]
    [ "$situation" = "aguardando_fzap" ]
)

test_staged_resume() (
    set -e
    load_setup

    events=""
    current="infra_pronta"
    situation="aguardando_fzap"
    nome_rede_interna=""

    dados() { :; }
    validar_rede_docker() { return 0; }
    rotacionar_log() { :; }
    log_tecnico() { :; }
    stack_saudavel() { return 1; }
    estado_ler() {
        case "$1" in
            "Situacao") echo "$situation" ;;
            "Etapa concluida") echo "$current" ;;
            "Fluxo de instalacao") echo "etapas" ;;
        esac
    }
    estado_restaurar_dados() {
        fluxo_instalacao="etapas"
        url_fzap="app.test"
        url_portainer="painel.test"
        email_ssl="admin@example.com"
        fzap_language="pt-BR"
        nome_rede_interna="proxy"
    }
    estado_alcancou() {
        case "$1" in
            verificado_servidor|dns_ok|dados_confirmados|infra_pronta) return 0 ;;
            *) return 1 ;;
        esac
    }
    decidir_depois_da_infraestrutura() { events="$events prompt"; return 0; }
    etapa4_instalar_so_infraestrutura() { events="$events infra"; return 0; }
    etapa4_instalar_so_fzap() { events="$events app"; return 0; }
    etapa5_verificar() { events="$events check"; return 0; }
    estado_gravar() { current="$1"; situation="${2:-em_andamento}"; }
    tela_conclusao_sucesso() { events="$events success"; }
    tela_ja_instalado() { events="$events already"; }
    tratar_falha() { return 1; }

    jornada_instalar_fzap "etapas"

    [ "$events" = " prompt app check success" ]
    [ "$current" = "concluido" ]
    [ "$situation" = "concluido" ]
)

test_complete_after_staged_pause() (
    set -e
    load_setup

    events=""
    current="infra_pronta"
    situation="aguardando_fzap"
    nome_rede_interna=""

    dados() { :; }
    validar_rede_docker() { return 0; }
    rotacionar_log() { :; }
    log_tecnico() { :; }
    stack_saudavel() { return 1; }
    estado_ler() {
        case "$1" in
            "Situacao") echo "$situation" ;;
            "Etapa concluida") echo "$current" ;;
        esac
    }
    estado_restaurar_dados() {
        fluxo_instalacao="etapas"
        url_fzap="app.test"
        url_portainer="painel.test"
        email_ssl="admin@example.com"
        fzap_language="pt-BR"
        nome_rede_interna="proxy"
    }
    estado_alcancou() { return 0; }
    etapa4_instalar() { events="$events complete"; return 0; }
    etapa4_instalar_so_fzap() { events="$events app"; return 0; }
    decidir_depois_da_infraestrutura() { events="$events prompt"; return 0; }
    etapa5_verificar() { events="$events check"; return 0; }
    estado_gravar() { current="$1"; situation="${2:-em_andamento}"; }
    tela_conclusao_sucesso() { events="$events success"; }
    tela_ja_instalado() { events="$events already"; }
    tratar_falha() { return 1; }

    jornada_instalar_fzap "completo"

    [ "$events" = " complete check success" ]
)

test_state_and_menu
test_environment_modes
test_staged_pause
test_staged_resume
test_complete_after_staged_pause

echo "setup_flouds_test: OK"
