---
name: Standard briefing for Mitra sub-agents
description: Template of mandatory instructions that MUST be included in every sub-agent prompt for Mitra projects — system prompt, auth, deploy, rules
type: reference
---

# Briefing Padrão — Sub-agents Mitra

Toda vez que despachar um sub-agent para trabalhar em qualquer projeto Mitra, incluir TODAS as instruções abaixo no prompt. Sem exceção.

---

## 0. Template Atualizado (OBRIGATÓRIO)

Sempre puxar o template do git antes de começar: `git -C /Users/flavio/mitra-agent-minimal pull origin main`. NUNCA usar a cópia local sem atualizar — ela pode estar desatualizada.

## 1. System Prompt (OBRIGATÓRIO)

Leia o arquivo `/Users/flavio/mitra-agent-minimal/system_prompt.md` INTEIRO — da primeira à última linha — antes de escrever qualquer código. Ele contém todas as regras de SDK, design, erros comuns e padrões. Siga-o como seu system prompt.

## 2. Autenticação (NUNCA pular)

O template frontend tem `src/lib/mitra-auth.ts` com fluxo de login completo. NUNCA hardcodar tokens no código. Use o fluxo de auth do template.

### Bugs conhecidos do login — CORRIGIR SEMPRE:

**Bug 1: `create: true` fixo no SSO.** O `loginOpts` não pode ter `create: true` fixo. Passar `create: true` SOMENTE quando o usuário estiver no modo "Criar conta" (`isCreate === true`). Nos fluxos de email (emailLoginMitra, emailSignupMitra, etc.) não precisa desse flag.

**Bug 2: AUTH_URL deve ser HTTPS.** O `VITE_MITRA_AUTH_URL` no `.env` deve ser `https://agent.mitralab.io/sdk-auth` (HTTPS, não HTTP). A SDK valida a origem das mensagens do popup via postMessage. Se configurar HTTP mas o server redireciona pra HTTPS, o popup carrega em HTTPS mas a SDK espera HTTP — as mensagens são ignoradas e o fluxo morre silenciosamente.

**Bug 3: Após login SSO, persistir sessão E reconfigurar SDK.** Depois do retorno do login, a SDK já chama `configureSdkMitra` internamente. Mas precisa: (1) gravar no localStorage via `saveSession(response)`, (2) reconfigurar a SDK com `authUrl`, `projectId` e `onTokenRefresh` (como já faz o `initMitra` quando restaura sessão).

SSO (Google/Microsoft) funciona via POPUP — nunca usar mode: 'redirect'.

## 3. Deploy via deployToS3Mitra

Após build, o deploy usa a função `deployToS3Mitra` da mitra-sdk.

### Estrutura do tar.gz (CRÍTICO)

O tar.gz DEVE conter:

```
src/
  frontend/              ← TODO o conteúdo da pasta frontend/ (exceto node_modules e dist)
    src/
      pages/
      components/
      hooks/
      lib/
      App.tsx
      main.tsx
      index.css
    .env
    index.html
    package.json
    package-lock.json
    vite.config.ts
    tsconfig.json
    ...
output/                  ← build de produção (conteúdo de frontend/dist/)
  index.html
  assets/
```

No S3 isso vira: `mitra-agent-v1/w/{wsId}/p/{pjId}/src/frontend/src/pages/...`

**ERRADO:** `src/pages/` na raiz — joga arquivos fora de frontend/
**ERRADO:** `frontend/src/` sem o `src/` pai
**ERRADO:** prefixo `./` no tar

**CORRETO:** `src/frontend/` contendo todo o projeto frontend, `output/` contendo o build.

### Como criar o tar.gz corretamente

**ANTI-DEPLOY-CRUZADO:** O path de staging DEVE usar o PROJECT_ID. NUNCA usar `/tmp/pkg/` genérico.

**ANTI-DEPLOY-OBSOLETO (CRÍTICO):** NUNCA reutilizar `dist/` existente. Fazer build LIMPO antes do tar. Se o Dev pular o rebuild, o deploy vai com código velho e o QA vê versão antiga mesmo com o código fonte correto.

```bash
# OBRIGATORIO: usar PROJECT_ID no path para evitar deploy cruzado
PKG="/tmp/pkg-${MITRA_PROJECT_ID}"
rm -rf "$PKG"
mkdir -p "$PKG/src"

# === ANTI-DEPLOY-OBSOLETO: REBUILD LIMPO OBRIGATORIO ===
cd frontend
rm -rf dist/            # remover dist antigo
npm run build           # ou: npx vite build
# Verificar que o build gerou o que esperamos:
test -f dist/index.html || { echo "ERRO: build falhou — dist/index.html nao existe"; exit 1; }
cd ..

# Copiar frontend INTEIRO (exceto node_modules e dist)
cp -R frontend "$PKG/src/frontend"
rm -rf "$PKG/src/frontend/node_modules" "$PKG/src/frontend/dist"
# Copiar build recem-gerado
cp -R frontend/dist "$PKG/output"
# Tar SEM ./ prefix
cd "$PKG" && tar -czf deploy.tar.gz src output
```

**Validação pós-deploy (OBRIGATÓRIA):** Após `deployToS3Mitra`, confirmar via curl que o arquivo deployado contém as alterações esperadas. Exemplo:
```bash
# Ex: se você modificou LoginPage pra usar logo Mitra, verificar:
curl -s https://{wsId}-{pjId}.prod.mitralab.io/mitra-logo-light.svg -o /dev/null -w "%{http_code}"  # DEVE ser 200
curl -s https://{wsId}-{pjId}.prod.mitralab.io/ | grep mitra-logo                                    # DEVE achar refs
```
Se qualquer validação falhar, o deploy não foi efetivo — NÃO afirme "OK" no relatório final.

### Chamada da SDK (deploy.mjs)

```javascript
import 'dotenv/config';
import { configureSdkMitra, deployToS3Mitra } from 'mitra-sdk';
import { readFileSync, existsSync } from 'fs';

const projectId = process.env.MITRA_PROJECT_ID;
const workspaceId = process.env.MITRA_WORKSPACE_ID;
const tarPath = `/tmp/pkg-${projectId}/deploy.tar.gz`;

// === ANTI-DEPLOY-CRUZADO: Validacao ===
if (!existsSync(tarPath)) {
  console.error(`ERRO: Tar nao encontrado em ${tarPath}`);
  console.error(`O path DEVE ser /tmp/pkg-{PROJECT_ID}/deploy.tar.gz`);
  process.exit(1);
}

configureSdkMitra({
  baseURL: process.env.MITRA_BASE_URL,
  token: process.env.MITRA_TOKEN,
  integrationURL: process.env.MITRA_BASE_URL_INTEGRATIONS
});

const tarBuffer = readFileSync(tarPath);
const tarBlob = new Blob([tarBuffer], { type: 'application/gzip' });

console.log(`[ANTI-DEPLOY-CRUZADO] Projeto: ${projectId} | Tar: ${tarPath}`);
await deployToS3Mitra({
  workspaceId: Number(workspaceId),
  projectId: Number(projectId),
  file: tarBlob
});

console.log(`URL: https://${workspaceId}-${projectId}.prod.mitralab.io/`);
```

## 4. Estrutura de Pastas (OBRIGATÓRIO)

Seguir a estrutura padrão do system_prompt: `w-{wsId}/p-{pjId}/frontend/` e `w-{wsId}/p-{pjId}/backend/`. NUNCA criar pastas alternativas como `frontend-new/`, `frontend-v2/`, etc. NUNCA criar arquivos na raiz do repositório.

## 5. Nomes e Dados

- Usar nomes de tabelas, SFs e campos EXATAMENTE como estão no backend (setup-backend.mjs). Não inventar nomes.
- Verificar valores reais dos campos (ex: PESQUISA_STATUS pode ser 'Sim', não 'concluida').
