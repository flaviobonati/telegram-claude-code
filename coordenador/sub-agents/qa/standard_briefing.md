---
name: Standard briefing for Mitra sub-agents
description: Template of mandatory instructions that MUST be included in every sub-agent prompt for Mitra projects — system prompt, auth, deploy, rules
type: reference
---

# Briefing Padrão — Sub-agents Mitra

Toda vez que despachar um sub-agent para trabalhar em qualquer projeto Mitra, incluir TODAS as instruções abaixo no prompt. Sem exceção.

---

## 0. Projeto LIMPO do Zero (OBRIGATÓRIO — NUNCA copiar projeto antigo)

**CADA sistema começa do ZERO.** O Coordenador cria a pasta vazia com apenas logos (.svg) e .env. O Dev puxa o template do git e desenvolve tudo do zero.

**PROIBIDO:** copiar código de projetos anteriores, reutilizar SFs de outro projeto, copiar frontend/src/ de projeto antigo. Isso contamina o one-shot e invalida os indicadores da fábrica.

O template do git tem os componentes UI base (Button, Card, Modal, etc.) — isso é suficiente. Todo o resto (pages, hooks, lib, backend) é criado do zero pelo Dev.

`git -C /Users/flavio/mitra-agent-minimal pull origin main` — puxar template limpo.

## 0.1. Logos Mitra (OBRIGATÓRIO — NUNCA gerar SVGs)

As logos da Mitra são arquivos SVG profissionais que DEVEM ser copiados de `/opt/mitra-factory/assets/`:

```bash
cp /opt/mitra-factory/assets/mitra-logo-light.svg frontend/public/mitra-logo-light.svg
cp /opt/mitra-factory/assets/mitra-logo-dark.svg frontend/public/mitra-logo-dark.svg
```

**NUNCA gere SVGs placeholder.** Os arquivos em `/opt/mitra-factory/assets/` são os logos oficiais (2074 bytes cada). Se você gerar um SVG genérico (375 bytes com retângulo + texto), o Flávio vai reprovar imediatamente.

## 0.2. Frontend .env (OBRIGATÓRIO — todas as variáveis)

O `.env` do frontend DEVE ter TODAS estas variáveis:

```
VITE_MITRA_BASE_URL=https://newmitra.mitrasheet.com:8080
VITE_MITRA_AUTH_URL=https://agent.mitralab.io/sdk-auth
VITE_MITRA_PROJECT_ID={projectId}
VITE_MITRA_WORKSPACE_ID=19103
VITE_MITRA_SERVICE_TOKEN=sk_333CHbqiqgRK1rmmstUWMdMc-rkPADlNNs0IimscKPYtAEepIpn7XzHc8ewD5_26
VITE_GEMINI_API_KEY=AIzaSyD-MomdTF3a89i70dEPwFNq6NZ3PTs3o8A
```

**Se faltar `VITE_MITRA_SERVICE_TOKEN`, o login temporário NÃO funciona** — a SDK precisa desse token pra chamar a SF de login antes do usuário estar autenticado.

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

## 6. Regras da Fábrica Mitra (OBRIGATÓRIAS)

### 6.1. Server Functions: usar o tipo CORRETO (conforme system_prompt.md)

Cada tipo de SF tem custo diferente. Usar o tipo errado deixa o sistema lento e é motivo de **rejeição imediata**.

| Necessidade | Tipo correto | Tempo |
|---|---|---|
| CRUD simples (1 tabela) | **REST** (listRecordsMitra, createRecordMitra, etc.) — NEM PRECISA de SF | ~5ms |
| Query de leitura (SELECT, joins, agregações) | SF tipo **SQL** | ~8ms |
| Mutação dinâmica (UPDATE/DELETE com lógica) | SF tipo **SQL** | ~8ms |
| Chamar API externa via integração | SF tipo **INTEGRATION** | ~500ms |
| Lógica complexa (loops, imports, orquestração) | SF tipo **JAVASCRIPT** | ~2000ms (sobe E2B) |

**REGRA:** SF de leitura de tela (listar registros, dashboards, filtros) NUNCA pode ser JAVASCRIPT. JavaScript sobe servidor efêmero E2B que leva segundos — o usuário espera 20s por algo de 8ms. 

**Antes de criar uma SF JAVASCRIPT, pergunte:** "isso pode ser feito com SQL puro ou REST?" Se sim, use SQL ou REST. JS só para lógica que SQL não consegue expressar (loops, chamadas encadeadas, processamento de dados).

### 6.2. Workers: NÃO implementar

Digital Workers NÃO são responsabilidade do Dev. O Mitra tem construtor nativo que será usado DEPOIS do sistema core funcionar. Ignore menções a workers na spec.

### 6.3. Sparkle = Genialidade de UX/UI (NÃO IA)

Sparkle é qualidade visual/interativa: drag-and-drop, animações, gráficos interativos, tooltips, micro-interações. NÃO é feature de IA forçada.

### 6.4. Smoke Test Backend (OBRIGATÓRIO antes de entregar)

O Dev DEVE testar CADA Server Function via backend (executeServerFunctionMitra) antes de entregar. NÃO usar Playwright — testar as SFs diretamente:

```javascript
// Para CADA SF, executar e verificar que retorna dados:
const sfs = await listServerFunctionsMitra({ projectId });
for (const sf of sfs) {
  try {
    const result = await executeServerFunctionMitra({ projectId, serverFunctionId: sf.id, input: {} });
    console.log(sf.name, '→', result.result?.output?.rowCount ?? 'OK');
  } catch(e) { console.log(sf.name, '→ ERRO:', e.message); }
}
```

**Se qualquer SF retorna erro, NÃO entregue. Corrija primeiro.**

### 6.5. listRecordsMitra retorna { content: [...] } (BUG SISTÊMICO)

**ATENÇÃO:** `listRecordsMitra` retorna `{ size, totalPages, page, content: [...] }`, NÃO um array direto. O frontend DEVE extrair `.content`:

```typescript
// CORRETO:
const res = await listRecordsMitra({ projectId, tableName });
const rows = res.content ?? res.records ?? (Array.isArray(res) ? res : []);

// ERRADO (causa white screen crash):
const rows = res; // ← .map() num objeto = crash
```

Todo wrapper de listRecords (api.ts, hooks, etc.) DEVE tratar `.content`. Se não tratar, TODAS as telas de CRUD crasham.

### 6.6. Checklist Pré-Entrega (OBRIGATÓRIO)

Antes de declarar pronto, verificar:
1. Título correto no HTML
2. Logos reais (2074 bytes, copiadas de /opt/mitra-factory/assets/)
3. Favicon = mitra-logo-dark.svg
4. Login funciona para CADA persona (testar SF com input)
5. Bundle compila sem erro
6. **ZERO Server Functions JavaScript desnecessárias** (listar todas e verificar tipo)
7. SF de login é PÚBLICA (togglePublicExecutionMitra)
8. **Smoke test: TODAS as SFs executadas via backend sem erro**
9. **listRecordsMitra .content tratado no frontend**

### 6.6B. Botão "Carregar Dados de Exemplo" em telas de import (OBRIGATÓRIO)

Em CADA tela de importação, upload ou disparo de cadeia de dados (Importar Vendas, Importar Produtos, Apurar, etc.), implementar um botão **"Carregar Dados de Exemplo"** que:

1. Insere 10-20 registros fictícios hardcoded no banco (sem IA, sem CSV externo)
2. Não depende de arquivo upload
3. Feedback visual: "15 vendas de exemplo carregadas"
4. Idempotente ou com marca de sessão

**Por quê:** QA usa esse botão pra disparar cadeias de fluxo de dados, Flávio usa o mesmo botão pra replicar o teste com 1 clique. Sem dependência externa de CSV.

Implementação simples:
```typescript
const sampleVendas = [
  { vendedor_email: 'ricardo@teste.com', sku: 'PROD001', valor: 5000, data: '2026-04-15' },
  // ... 10-20 linhas hardcoded
];
<Button onClick={async () => {
  await executeServerFunctionMitra({ projectId, serverFunctionId: sfProcessarVendas, input: { vendas: sampleVendas } });
  toast.success('15 vendas de exemplo carregadas');
}}>Carregar Dados de Exemplo</Button>
```

### 6.7. Botões de Login Rápido na Tela de Login (OBRIGATÓRIO)

A tela de login DEVE ter botões de acesso rápido para CADA usuário temporário. Exemplo:

```
[Admin - Paulo]  [Gestor - Ricardo]  [Vendedor - Fernanda]  [Financeiro - Débora]
```

Ao clicar, preenche email e senha automaticamente e faz login direto. Isso permite testar qualquer persona em 1 clique.

### 6.8. Login Temporário

SF de login DEVE ser:
- Tipo: SQL
- Query: `SELECT ID, NOME, EMAIL, PERFIL FROM USUARIOS_TEMPORARIOS WHERE EMAIL = '{{email}}' AND SENHA = '{{senha}}' LIMIT 1`
- Pública: `togglePublicExecutionMitra({ projectId, serverFunctionId, publicExecution: true })`
