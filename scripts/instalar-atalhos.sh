#!/data/data/com.termux/files/usr/bin/sh
# Instala, no Termux, o atalho "Iniciar Tp" (Termux:Widget) e o
# início automático no boot (Termux:Boot) para o servidor do Prompter.
#
# Uso (dentro da pasta do projeto, no Termux):
#   sh scripts/instalar-atalhos.sh

set -e

# Caminho absoluto do projeto (a pasta acima de scripts/).
PROJ="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PRINCIPAL="$PROJ/scripts/iniciar-tp.sh"

mkdir -p "$HOME/.shortcuts" "$HOME/.termux/boot"

# ── Atalho de um toque (Termux:Widget) ──
# O nome do arquivo (sem .sh) é o que aparece no widget.
ATALHO="$HOME/.shortcuts/Iniciar Tp.sh"
printf '#!/data/data/com.termux/files/usr/bin/sh\nexec sh "%s"\n' \
  "$SCRIPT_PRINCIPAL" > "$ATALHO"
chmod +x "$ATALHO"

# ── Início automático no boot (Termux:Boot) ──
BOOT="$HOME/.termux/boot/start-prompter.sh"
printf '#!/data/data/com.termux/files/usr/bin/sh\nexec sh "%s"\n' \
  "$SCRIPT_PRINCIPAL" > "$BOOT"
chmod +x "$BOOT"

echo ""
echo "Atalhos instalados!"
echo " - Widget:  Termux:Widget -> 'Iniciar Tp'"
echo " - Boot:    sobe sozinho ao ligar o tablet"
echo ""
echo "Projeto detectado em: $PROJ"
echo ""
echo "PRÓXIMOS PASSOS:"
echo " 1. Instale Termux:Widget e Termux:Boot (F-Droid)"
echo " 2. Adicione o widget do Termux:Widget na tela inicial"
echo " 3. Abra o Termux:Boot uma vez (ativa o boot automático)"
echo " 4. Toque em 'Iniciar Tp' no widget — pronto!"
