# TVWEB Prompter

Teleprompter web com **sincronização remota em tempo real** entre dispositivos
(ex.: dois Galaxy Tab S10 Lite). Um tablet pode ler a pauta enquanto o outro
controla play/pause, velocidade, saltos de bloco e **edita o texto à distância**.

## Como funciona

- Hospedagem do app: **Netlify** (site estático, HTTPS grátis).
- Sincronização em tempo real: **Firebase Realtime Database** (plano gratuito).
- Os dois tablets abrem a mesma URL e digitam o **mesmo código de sala**.
  Pauta, ajustes e controles passam a ficar sincronizados instantaneamente.

> Sem configurar o Firebase, o app funciona normalmente, só **sem** a
> sincronização entre tablets (modo offline / um aparelho só).

## 1. Criar o projeto Firebase (≈ 5 min)

1. Acesse <https://console.firebase.google.com> e clique em **Adicionar projeto**.
2. Com o projeto criado, no menu lateral abra **Realtime Database** → **Criar banco de dados**.
   - Escolha a localização e o modo de teste.
3. Em **Realtime Database → Regras**, para testar rápido use:
   ```json
   { "rules": { ".read": true, ".write": true } }
   ```
   (Depois dá pra restringir; veja a seção Segurança abaixo.)
4. Vá em **⚙️ Configurações do projeto → Seus apps → App da Web (`</>`)**,
   registre um app e copie o objeto `firebaseConfig`.

## 2. Colar as chaves no app

No arquivo `index.html`, localize o bloco **`firebaseConfig`** (está comentado
e fácil de achar) e cole seus valores:

```js
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  databaseURL: "https://SEU-PROJETO.firebaseio.com",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "..."
};
```

## 3. Publicar no Netlify

Opção mais simples (deploy automático pelo GitHub):

1. Acesse <https://app.netlify.com> → **Add new site → Import an existing project**.
2. Conecte ao repositório `ofernandojr/fejr99`.
3. Build command: *(vazio)* · Publish directory: `.` (já definido em `netlify.toml`).
4. Deploy. O Netlify gera uma URL pública (ex.: `https://seu-app.netlify.app`).

> A cada `git push` o Netlify republica sozinho.

## 4. Usar nos dois tablets

1. Abra a URL do Netlify nos dois tablets.
2. No campo **Sincronização remota**, digite o mesmo código de sala
   (ex.: `tvweb1`) nos dois e toque em **Conectar** (indicador fica verde).
3. Pronto:
   - Edite a pauta em qualquer tablet → aparece no outro na hora.
   - Ajuste fonte/margem/velocidade → sincroniza.
   - Play/pause, velocidade e saltos de bloco no prompter são compartilhados.

## Segurança (opcional, recomendado depois)

As regras abertas (`.read/.write: true`) servem para testes. Para uso real,
considere restringir por sala ou ativar autenticação anônima no Firebase.
Como o código da sala não é secreto, evite usar nomes óbvios em produção.

---
desenvolvido por Fernando Junior
