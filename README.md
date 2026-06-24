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

## Conexão offline (sem internet)

Dá para sincronizar os dois tablets **sem internet**, ligando um ao outro
direto pela rede local (mesma Wi-Fi ou pelo **hotspot de um dos tablets** —
o hotspot não precisa ter internet, só servir de rede entre eles). Usa
**WebRTC ponto-a-ponto**, com o pareamento inicial feito por **QR Code**.

### Requisito (só na primeira vez, com internet)

O app precisa ser aberto **uma vez com internet** pela URL do Netlify para o
**Service Worker** guardar tudo em cache (vira PWA). Depois disso, abrir a
mesma URL funciona offline — e como continua sob HTTPS, a câmera e o WebRTC
funcionam. Dica: "Adicionar à tela inicial" nos dois tablets.

### Como parear

1. Coloque os dois tablets na mesma Wi-Fi (ou ligue o hotspot de um e conecte
   o outro nele).
2. No tablet que vai **controlar**: toque em **Criar conexão (este controla)**.
   Ele mostra um QR Code.
3. No tablet de **exibição**: toque em **Entrar (ler QR)** e aponte a câmera
   para o QR do controle. Ele gera um **QR de resposta**.
4. No tablet de controle: toque em **Ler QR de resposta** e aponte para o QR
   do outro. Pronto — aparece "🔗 Conectado".

A partir daí, pauta, ajustes e controles sincronizam direto entre os dois,
sem nuvem. O pareamento por QR é refeito a cada nova sessão.

> Quando há internet, o modo Firebase (sala) é mais prático e instantâneo;
> o modo offline é o plano para quando não houver rede.

## Controle Bluetooth

Na tela de edição há a seção **Controle Bluetooth**. Toque em **Mapear** ao lado
da ação desejada (play, velocidade, blocos, blackout) e pressione o botão no
controle. Funciona com:

- **Apresentadores/remotos** que enviam teclas (mais comum) — capturado como tecla.
- **Gamepads** — capturado pela Gamepad API (aparece "🎮 Gamepad conectado").

O mapeamento fica salvo no próprio tablet. Já vem com um padrão de teclado
(Espaço = play, setas = velocidade/blocos, Esc = blackout).

## Segurança (opcional, recomendado depois)

As regras abertas (`.read/.write: true`) servem para testes. Para uso real,
considere restringir por sala ou ativar autenticação anônima no Firebase.
Como o código da sala não é secreto, evite usar nomes óbvios em produção.

---
desenvolvido por Fernando Junior
