#!/data/data/com.termux/files/usr/bin/sh
# Instala, no Termux, o atalho de um toque (Termux:Widget) e o
# início automático no boot (Termux:Boot) para o servidor do Prompter.
#
# Uso (dentro da pasta do projeto, no Termux):
#   sh scripts/instalar-atalhos.sh

set -e

# Caminho absoluto do projeto (a pasta acima de scripts/).
PROJ="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$HOME/.shortcuts" "$HOME/.termux/boot"

# Conteúdo do launcher, já apontando para a pasta correta do projeto.
LAUNCHER="#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock 2>/dev/null
cd \"$PROJ\"
exec node server.js
"

# 1) Atalho de um toque (aparece no widget do Termux:Widget)
printf '%s' "$LAUNCHER" > "$HOME/.shortcuts/Prompter.sh"
chmod +x "$HOME/.shortcuts/Prompter.sh"

# 2) Início automático ao ligar o tablet (Termux:Boot)
printf '%s' "$LAUNCHER" > "$HOME/.termux/boot/start-prompter.sh"
chmod +x "$HOME/.termux/boot/start-prompter.sh"

echo "OK! Atalhos instalados apontando para: $PROJ"
echo " - Um toque:  Termux:Widget -> 'Prompter'"
echo " - No boot:   Termux:Boot (sobe sozinho ao ligar o tablet)"
