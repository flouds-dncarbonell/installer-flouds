# Teste do FZAP no Easypanel

O template cria:

- um serviço PostgreSQL 17 com pgvector;
- um serviço FZAP publicado na porta interna `8080`;
- senha do banco e `ADMIN_TOKEN` aleatórios;
- três volumes persistentes da aplicação;
- todas as variáveis opcionais da stack.

## Gerar o JSON de teste

Execute localmente:

```bash
node deploy/easypanel/generate-template.mjs > /tmp/fzap-easypanel.json
```

O JSON contém credenciais geradas no momento da execução. Não o versione.

## Importar

1. No Easypanel, abra **Templates**.
2. Escolha a opção para criar/importar um template a partir de JSON.
3. Cole o conteúdo de `/tmp/fzap-easypanel.json`.
4. Escolha o nome do projeto e crie os serviços.
5. No serviço `fzap`, substitua o domínio gerado pelo domínio definitivo.
6. Confirme que o proxy usa a porta `8080`.

O `PUBLIC_BASE_URL` usa `https://$(PRIMARY_DOMAIN)` e acompanha o domínio
marcado como principal no Easypanel.

O token administrativo pode ser consultado na variável `ADMIN_TOKEN` do
serviço FZAP.

## Fonte do template oficial

Os arquivos `meta.yaml` e `index.ts` seguem o formato do repositório oficial de
templates do Easypanel e podem ser testados no playground ou submetidos à
galeria.
