# TVWEB Prompter

Teleprompter que roda no navegador. Você escreve o texto, ele rola na tela
grande e você lê olhando para a câmera.

Dá para usar **um aparelho só**. E dá para usar **dois**: um mostra o texto e o
outro comanda (play, velocidade, pular bloco, tela preta). Tudo pela rede local
— **sem internet e sem nuvem**.

---

## Usar em um aparelho só

1. Abra o app no navegador.
2. **Passo 1:** escreva ou cole o texto e toque em *ADICIONAR À LISTA*.
3. **Passo 3:** ajuste o tamanho da letra e a velocidade.
4. Toque em **INICIAR TELEPROMPTER**.

Na tela do prompter:

| O que fazer | O que acontece |
| --- | --- |
| Um toque na tela | Começa / pausa |
| Arrastar para cima ou para baixo | Rola o texto |
| Botões **−** e **+** | Mudam a velocidade |
| Botões **&#124;◀** e **▶&#124;** | Pulam para o bloco anterior / seguinte |
| Botão **⟵ VOLTAR** | Sai do prompter |

O texto fica salvo sozinho no aparelho. Fechar o app não apaga nada.

### Trazer o texto de um arquivo

Em *Passo 2 → Salvar ou abrir um texto do aparelho* há **Importar TXT ou Word**.
Aceita:

- **`.txt`** em qualquer codificação (o TXT que o Word gera costuma ser ANSI ou
  UTF-16, não UTF-8 — o app detecta sozinho e os acentos saem certos).
- **`.docx`** — o Word moderno. É lido direto no aparelho, sem internet e sem
  mandar o arquivo para lugar nenhum.

Cada trecho separado por **linha em branco** vira um bloco. Assim os botões de
pular bloco funcionam. Se o arquivo não tiver linhas em branco, cada linha vira
um bloco.

> **`.doc`** (Word antigo, antes de 2007) não abre. No Word, use *Salvar como* e
> escolha `.docx` ou `.txt`.

> **Espelhar texto** já vem ligado. Isso é para quem usa um vidro/espelho na
> frente da câmera. Se você lê direto da tela, desligue no Passo 3.

### Mouse andando ao contrário

Em suporte de teleprompter o aparelho fica girado e o cursor anda invertido: a
mão vai para um lado e ele vai para o outro. Marque **Corrigir o mouse** no
Passo 3 — ele inverte os dois eixos, esquerda/direita e cima/baixo.

Dentro do prompter, o cursor do sistema é escondido e o app desenha o próprio
ponteiro (uma cruz branca), que anda no sentido certo. O clique vale para o
botão sob essa cruz. Fora do prompter o mouse continua como sempre.

A correção vale **só para o mouse**. O toque na tela continua funcionando
normalmente com a opção ligada: dedo clica os botões direto, sem passar pela
cruz.

> O navegador não consegue inverter o cursor do sistema; por isso o app desenha
> um ponteiro próprio em vez de tentar mexer no do Android.

---

## Usar em dois aparelhos

Um aparelho vira o **servidor**: ele guarda o texto e repassa tudo para o outro.

### Instalar (uma vez só, no aparelho que vai comandar)

Instale o **Termux** (recomendado pela F-Droid), abra e cole os comandos abaixo
**um de cada vez**, esperando cada um terminar.

> **Atenção ao til (`~`).** Em vários teclados de tablet ele sai como `-` e o
> comando quebra com `OLDPWD not set`. Por isso os comandos aqui usam `$HOME`
> no lugar de `~`. Digite `$HOME` mesmo, com o cifrão.

**1. Instalar os programas**

```sh
pkg update && pkg install nodejs git
```

Quando perguntar `Continue? [Y/n]`, responda `y` e Enter. Se responder que já
estão na versão mais nova, está certo — pode seguir.

> Só esses dois. Nada mais precisa ser instalado: o QR Code de conexão é
> desenhado pelo próprio projeto.

**2. Baixar o projeto**

```sh
git clone https://github.com/ofernandojr/tptvweb.git
```

Se aparecer `destination path 'tptvweb' already exists`, é porque você já
baixou antes. Nesse caso, em vez de baixar de novo, atualize:

```sh
cd $HOME/tptvweb && git pull
```

**3. Instalar os atalhos**

```sh
cd $HOME/tptvweb && sh scripts/instalar-atalhos.sh
```

**4. Conferir que deu certo**

```sh
cd $HOME/tptvweb && ls scripts
```

Tem que listar `atualizar-tp.sh`, `conectar-tp.sh`, `iniciar-tp.sh` e
`instalar-atalhos.sh`.

**5. Widgets**

Instale também os apps **Termux:Widget** e **Termux:Boot** (mesma loja do
Termux). Depois, na tela inicial do aparelho: segure o dedo num espaço vazio →
**Widgets** → **Termux:Widget**. Vão aparecer três atalhos:

| Atalho | Para que serve | Em qual aparelho |
| --- | --- | --- |
| **Iniciar Servidor** | Liga o servidor | No que comanda |
| **Conectar Tp** | Acha o servidor e abre o app | No que exibe |
| **Atualizar Tp** | Baixa a versão nova | No que comanda |

**6. Início automático**

Abra o **Termux:Boot** uma vez. A partir daí o servidor sobe sozinho quando o
aparelho liga.

### Se algo der errado na instalação

| O que apareceu | O que fazer |
| --- | --- |
| `bash: cd: OLDPWD not set` | Seu teclado trocou `~` por `-`. Use `$HOME`. |
| `destination path 'tptvweb' already exists` | Já está baixado. Use `cd $HOME/tptvweb && git pull`. |
| `No command run found` | Você digitou a frase `Run 'apt list --upgradable'`, que é só um aviso do Termux, não um comando. Ignore. |
| `22 packages can be upgraded` | Só um aviso. Não precisa fazer nada. |
| `Unable to locate package qrencode` | Esse pacote não existe no Termux e não é mais necessário — instale só `nodejs git`. |
| **Conectar Tp** não acha o servidor | Ele mostra na tela quais redes conseguiu enxergar. Veja a seção abaixo. |
| `Authentication failed` no `git clone` | O repositório precisa estar público. Confira em <https://github.com/ofernandojr/tptvweb>. |

### Usar no dia a dia

No aparelho que comanda, toque em **Iniciar Servidor**. A tela do Termux mostra
**o passo a passo completo, já com o endereço certo** — é só seguir o que estiver
escrito ali.

Resumo do que ela pede:

1. Ligar o **hotspot** do aparelho que roda o servidor.
2. Conectar o outro aparelho nesse hotspot (ou pôr os dois na mesma Wi-Fi).
3. Abrir `http://localhost:8080` no aparelho do servidor.
4. Abrir o endereço que o Termux mostrou (tipo `http://192.168.43.1:8080`) no
   outro aparelho. Há três jeitos, do mais fácil ao mais manual:
   **apontar a câmera para o QR Code que o Termux desenha na tela**, usar o
   atalho **Conectar Tp** (procura o servidor sozinho), ou digitar o endereço.
5. Conferir se aparece **✔ Conectado ao servidor** no topo do app.

**Deixe a janela do Termux aberta** — fechar derruba o servidor. Voltar para a
tela inicial é normal, ele continua rodando por trás.

Tocar em **Iniciar Servidor** de novo, com o servidor já rodando, **não
reinicia nada**: ele só reabre o app no navegador, mostra o endereço e o QR, e
fecha a janela. O servidor em execução não é tocado.

Daí em diante, o que você mudar num aparelho aparece no outro na hora: texto,
tamanho da letra, velocidade, rolagem, play/pause e tela preta.

> Não existe campo para digitar endereço dentro do app: quem abre pelo endereço
> do servidor já entra sincronizado.

> Para deixar o app com cara de aplicativo, use "Adicionar à tela inicial" no
> menu do navegador, nos dois aparelhos.

### Conectar pelo QR Code

Aparece em dois lugares, os dois com o mesmo endereço:

- **Na tela do Termux**, logo depois de tocar em **Iniciar Servidor**. É o mais
  prático: o outro aparelho aponta a câmera e abre o app já conectado.
- **Dentro do app**, no Passo 4, para repassar a conexão a um terceiro aparelho
  sem voltar ao Termux.

Os dois levam sempre o **endereço de rede**, nunca `localhost`. Mesmo quando você
abre o app por `http://localhost:8080`, ele pergunta ao servidor qual é o IP da
rede e monta o QR com ele — `localhost` só valeria no próprio aparelho.

### Quando o "Conectar Tp" não acha o servidor

Ele varre a rede inteira e imprime o que descobriu antes de desistir. Leia
essas linhas:

- **Mostrou endereços e redes, mas não achou** — os dois aparelhos provavelmente
  estão em redes diferentes. Os endereços precisam começar com os mesmos três
  números do que o servidor mostrou.
- **Disse `nenhuma` em todas as fontes** — o Android bloqueou a leitura da rede
  para o Termux (acontece do Android 11 em diante). Não há o que consertar no
  script: use o QR ou digite o endereço.
- **Disse que este aparelho está com versão antiga** — cada aparelho tem a sua
  própria cópia do projeto. Atualizar um não atualiza o outro. Rode
  **Atualizar Tp** neste aparelho.

Sempre funciona, em qualquer caso: aponte a câmera para o **QR Code** que a tela
do **Iniciar Servidor** mostra, ou digite no navegador o endereço que aparece
ali.

### Comandar do outro aparelho

No topo do app, toque em **🎮 Controle Remoto**. A tela vira um painel de
botões grandes: PLAY, anterior/próximo, − VEL / + VEL e BLACKOUT (tela preta).

Se esse aparelho também mostrar o texto, marque *Não espelhar neste aparelho*
no Passo 3 — o espelho continua valendo só na tela de exibição.

---

## Atualizar

No aparelho que roda o servidor, toque no atalho **Atualizar Tp**. Depois toque
em **Iniciar Servidor** de novo e recarregue a página nos dois aparelhos.

Pelo Termux, na mão:

```sh
cd $HOME/tptvweb && git pull
```

Se o `git pull` reclamar de arquivos alterados no aparelho, isto descarta as
alterações locais e deixa igual ao GitHub (apaga o que foi mudado ali):

```sh
cd $HOME/tptvweb && git fetch origin && git reset --hard origin/main
```

---

## Controle Bluetooth

Apresentadores e controles Bluetooth aparecem para o navegador como teclado.
As teclas abaixo já funcionam, sem configurar nada — tanto com o prompter
aberto quanto no painel de Controle Remoto:

| Tecla | Ação |
| --- | --- |
| Espaço | Começa / pausa |
| Seta ↑ / ↓ | Aumenta / diminui a velocidade |
| Seta → / ← (ou Page Down / Page Up) | Próximo / bloco anterior |
| Esc | Tela preta |

---

## Se não conectar

Confira nesta ordem:

1. O atalho **Iniciar Servidor** está rodando no aparelho que comanda?
2. O hotspot dele está ligado?
3. O outro aparelho está conectado nesse hotspot (ou na mesma Wi-Fi)?
4. O endereço aberto no navegador é o mesmo que a tela do Termux mostrou?

Se apareceu mais de um endereço no Termux, teste de cima para baixo até um
abrir.

---

## Sobre a rede

O `server.js` não tem senha e aceita qualquer origem — ele foi feito para uma
rede local fechada (o hotspot entre os dois aparelhos). **Não abra a porta 8080
para a internet** nem rode o servidor numa Wi-Fi pública: qualquer um na mesma
rede consegue ler e alterar o texto.

---
desenvolvido por Fernando Junior
