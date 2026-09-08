# TVWEB Prompter

Teleprompter web com **sincronização em tempo real entre dispositivos**
(ex.: dois Galaxy Tab S10 Lite), rodando **100% na rede local, sem internet
e sem nuvem**. Um tablet roda o servidor (Termux) e serve o app; os dois
abrem o mesmo endereço e passam a compartilhar pauta, ajustes e controles.

Um tablet pode exibir a pauta enquanto o outro controla play/pause,
velocidade, saltos de bloco, blackout e edita o texto à distância.

## Como funciona

- Um dos dispositivos roda **`server.js`** (Node.js, sem dependências) no Termux.
- Esse mesmo servidor **serve o app** e mantém o **estado compartilhado**.
- A sincronização é via **SSE** (`/events`) + **POST** (`/update`).
- Funciona na mesma Wi-Fi **ou pelo hotspot do tablet que roda o servidor**
  — o hotspot não precisa de internet, só de servir como rede entre eles.

> Sem servidor o app funciona normalmente, só **sem** sincronização
> (um aparelho só). A pauta e os ajustes ficam salvos no próprio dispositivo.

## Setup no tablet "servidor" (uma vez)

1. Instale o **Termux** (recomendado pela F-Droid).
2. No Termux:
   ```sh
   pkg update && pkg install nodejs git netcat-openbsd
   git clone https://github.com/ofernandojr/fejr99.git
   cd fejr99
   node server.js
   ```
   (`netcat-openbsd` fornece o `nc`, usado pelos scripts de atalho. Sem git,
   dá para copiar a pasta do projeto para o tablet e rodar `node server.js` dentro dela.)
3. O Termux mostra os endereços. Deixe rodando.

## Usar

1. No tablet do servidor, **ligue o hotspot** e conecte o outro tablet nele
   (ou ponha os dois na mesma Wi-Fi).
2. Descubra o IP do tablet servidor (no hotspot do Android costuma ser
   `192.168.43.1`; ou rode `ifconfig` no Termux).
3. **Tablet servidor:** abra `http://localhost:8080`.
   **Outro tablet:** abra `http://192.168.43.1:8080` (o IP do servidor).
4. Pronto — ao abrir pelo servidor, eles conectam **sozinhos** (aparece
   "🔗 Conectado ao servidor"). Edite num, aparece no outro.

Para facilitar o passo 3, o botão **Gerar QR de acesso** mostra um QR com o
endereço do servidor: o outro tablet aponta a câmera e abre direto.

> Dica: deixe o tablet de **controle** rodando o servidor. Como o app é servido
> por ele, o tablet de exibição não precisa de mais nada além de abrir o IP.
> O campo "Servidor local" também aceita digitar o endereço manualmente.

## Papéis: Exibição e Controle Remoto

No topo da tela há dois botões:

- **📺 Exibição / Edição** — editor da pauta, ajustes e o prompter em si.
- **🎮 Controle Remoto** — painel com botões grandes (play, blocos, velocidade,
  blackout) para pilotar o outro tablet. O papel escolhido fica salvo no aparelho.

Em **Ajustes** há ainda o *Modo Controlador*, que desliga o espelhamento do
texto **só neste tablet** (útil quando o controle também mostra a pauta).

## Não digitar comando toda vez (atalho de um toque + boot)

Para não rodar `node server.js` manualmente sempre:

1. Instale os apps **Termux:Widget** e **Termux:Boot** (mesma fonte do Termux, ex.: F-Droid).
2. No Termux, dentro da pasta do projeto, rode **uma vez**:
   ```sh
   sh scripts/instalar-atalhos.sh
   ```
   Isso cria automaticamente:
   - **Atalho "Iniciar Tp"** (tablet servidor/controle): adicione o widget do
     Termux:Widget na tela inicial e toque — o servidor sobe na hora.
   - **Atalho "Conectar Tp"** (tablet de exibição): procura o servidor na rede
     e abre o navegador já no app.
   - **Início automático:** o servidor passa a subir sozinho quando o tablet liga
     (Termux:Boot). Basta abrir o Termux:Boot uma vez após instalar, para ativá-lo.
3. Deixe o app na tela inicial como **PWA** ("Adicionar à tela inicial").

Os scripts usam `termux-wake-lock` para o servidor não ser suspenso pelo Android.
Se o projeto não estiver em `~/fejr99`, o instalador detecta o caminho correto
sozinho (ele usa a pasta onde o projeto está).

## Controle Bluetooth

Na tela de edição há a seção **Controle Bluetooth**. Toque em **Mapear** ao lado
da ação desejada (play, velocidade, blocos, blackout) e pressione o botão no
controle. Funciona com:

- **Apresentadores/remotos** que enviam teclas (mais comum) — capturado como tecla.
- **Gamepads** — capturado pela Gamepad API (aparece "🎮 Gamepad conectado").

O mapeamento fica salvo no próprio tablet. Já vem com um padrão de teclado
(Espaço = play, setas = velocidade/blocos, Esc = blackout). As ações valem tanto
com o prompter aberto quanto no painel de Controle Remoto.

## Segurança

O `server.js` não tem autenticação e libera CORS para qualquer origem — ele foi
feito para uma rede local fechada (hotspot entre os dois tablets). **Não exponha
a porta 8080 para a internet** nem rode o servidor em uma Wi-Fi pública: qualquer
um na mesma rede consegue ler e alterar a pauta.

---
desenvolvido por Fernando Junior
