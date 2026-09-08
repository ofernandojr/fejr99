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

> **Espelhar texto** já vem ligado. Isso é para quem usa um vidro/espelho na
> frente da câmera. Se você lê direto da tela, desligue no Passo 3.

### Mouse com o aparelho girado 180°

Em suporte de teleprompter o aparelho costuma ficar de cabeça para baixo. Aí o
cursor anda ao contrário: a mão vai para a direita e ele vai para a esquerda.

Marque **Corrigir o mouse** no Passo 3. Dentro do prompter, o cursor do sistema
é escondido e o app passa a desenhar o próprio ponteiro (uma cruz branca), que
anda no sentido certo. O clique vale para o botão que está sob essa cruz.

Só vale dentro do prompter — na tela de edição o mouse continua como sempre.

> O navegador não consegue inverter o cursor do sistema; por isso o app desenha
> um ponteiro próprio em vez de tentar mexer no do Android.

---

## Usar em dois aparelhos

Um aparelho vira o **servidor**: ele guarda o texto e repassa tudo para o outro.

### Instalar (uma vez só, no aparelho que vai comandar)

1. Instale o **Termux** (recomendado pela F-Droid).
2. Abra o Termux e cole, uma linha de cada vez:

   ```sh
   pkg update && pkg install nodejs git netcat-openbsd
   ```

   ```sh
   git clone https://github.com/ofernandojr/tptvweb.git
   ```

   ```sh
   cd tptvweb && sh scripts/instalar-atalhos.sh
   ```

3. Instale também os apps **Termux:Widget** e **Termux:Boot** (mesma loja).
4. Na tela inicial do aparelho: segure o dedo num espaço vazio → **Widgets** →
   **Termux:Widget**. Vão aparecer três atalhos:

   | Atalho | Para que serve | Em qual aparelho |
   | --- | --- | --- |
   | **Iniciar Servidor** | Liga o servidor | No que comanda |
   | **Conectar Tp** | Acha o servidor e abre o app | No que exibe |
   | **Atualizar Tp** | Baixa a versão nova | No que comanda |

5. Abra o **Termux:Boot** uma vez. Assim o servidor sobe sozinho quando o
   aparelho liga.

### Usar no dia a dia

No aparelho que comanda, toque em **Iniciar Servidor**. A tela do Termux mostra
**o passo a passo completo, já com o endereço certo** — é só seguir o que estiver
escrito ali.

Resumo do que ela pede:

1. Ligar o **hotspot** do aparelho que roda o servidor.
2. Conectar o outro aparelho nesse hotspot (ou pôr os dois na mesma Wi-Fi).
3. Abrir `http://localhost:8080` no aparelho do servidor.
4. Abrir o endereço que o Termux mostrou (tipo `http://192.168.43.1:8080`) no
   outro aparelho — ou usar nele o atalho **Conectar Tp**, que procura sozinho.
5. Conferir se aparece **✔ Conectado ao servidor** no topo do app.

**Deixe a janela do Termux aberta** — fechar derruba o servidor. Voltar para a
tela inicial é normal, ele continua rodando por trás.

Daí em diante, o que você mudar num aparelho aparece no outro na hora: texto,
tamanho da letra, velocidade, rolagem, play/pause e tela preta.

> Não existe campo para digitar endereço dentro do app: quem abre pelo endereço
> do servidor já entra sincronizado.

> Para deixar o app com cara de aplicativo, use "Adicionar à tela inicial" no
> menu do navegador, nos dois aparelhos.

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
cd ~/tptvweb && git pull
```

Se o `git pull` reclamar de arquivos alterados no aparelho, isto descarta as
alterações locais e deixa igual ao GitHub (apaga o que foi mudado ali):

```sh
cd ~/tptvweb && git fetch origin && git reset --hard origin/main
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
