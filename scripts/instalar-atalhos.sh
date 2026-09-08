#!/data/data/com.termux/files/usr/bin/sh
# Instala, no Termux, os atalhos de um toque (Termux:Widget) e o
# inicio automatico no boot (Termux:Boot) do TVWEB Prompter.
#
# Uso (dentro da pasta do projeto, no Termux):
#   sh scripts/instalar-atalhos.sh

set -e

# Caminho absoluto do projeto (a pasta acima de scripts/).
PROJ="$(cd "$(dirname "$0")/.." && pwd)"

# ── Teclado virtual fora do caminho ──
# O atalho abre uma sessao do Termux so para MOSTRAR o passo a passo e o QR;
# nao ha nada para digitar, e o teclado cobria metade da tela.
PROPS="$HOME/.termux/termux.properties"
mkdir -p "$HOME/.termux"
if grep -q '^hide-soft-keyboard-on-startup[[:space:]]*=[[:space:]]*true' "$PROPS" 2>/dev/null; then
  echo "[OK] Ajuste do teclado ja estava aplicado."
elif grep -q '^hide-soft-keyboard-on-startup' "$PROPS" 2>/dev/null; then
  # Existe, mas com outro valor: corrige em vez de duplicar a linha.
  sed -i 's/^hide-soft-keyboard-on-startup.*/hide-soft-keyboard-on-startup=true/' "$PROPS"
  echo "[OK] Teclado virtual nao vai mais abrir sozinho."
  RECARREGAR=1
else
  printf '
# TVWEB Prompter: nao abrir o teclado virtual ao iniciar
hide-soft-keyboard-on-startup=true
' >> "$PROPS"
  echo "[OK] Teclado virtual nao vai mais abrir sozinho."
  RECARREGAR=1
fi

mkdir -p "$HOME/.shortcuts" "$HOME/.termux/boot"

# ── Atalhos de um toque (Termux:Widget) ──
# O nome do arquivo (sem .sh) e o que aparece no widget.
criar_atalho() {
  ARQ="$HOME/.shortcuts/$1.sh"
  printf '#!/data/data/com.termux/files/usr/bin/sh\nexec sh "%s/scripts/%s"\n' \
    "$PROJ" "$2" > "$ARQ"
  chmod +x "$ARQ"
}

# Remove o nome antigo, se existir de uma instalacao anterior.
rm -f "$HOME/.shortcuts/Iniciar Tp.sh"

criar_atalho "Iniciar Servidor" "iniciar-tp.sh"
criar_atalho "Conectar Tp"      "conectar-tp.sh"
criar_atalho "Atualizar Tp"     "atualizar-tp.sh"

# ── Inicio automatico no boot (Termux:Boot) ──
BOOT="$HOME/.termux/boot/start-prompter.sh"
printf '#!/data/data/com.termux/files/usr/bin/sh\nexec sh "%s/scripts/iniciar-tp.sh"\n' \
  "$PROJ" > "$BOOT"
chmod +x "$BOOT"

if [ "$RECARREGAR" = "1" ] && command -v termux-reload-settings >/dev/null 2>&1; then
  termux-reload-settings >/dev/null 2>&1 || true
fi

echo ""
echo "=============================================="
echo "  ATALHOS INSTALADOS"
echo "=============================================="
echo ""
echo "  Iniciar Servidor  - no aparelho que comanda"
echo "  Conectar Tp       - no aparelho que exibe"
echo "  Atualizar Tp      - baixa a versao nova"
echo ""
echo "  Boot: o servidor sobe sozinho ao ligar o"
echo "        aparelho que roda o servidor."
echo ""
echo "  Projeto detectado em: $PROJ"
echo ""
echo "=============================================="
echo "  FALTA FAZER (uma vez so)"
echo "=============================================="
echo ""
echo "  1. Instale os apps Termux:Widget e"
echo "     Termux:Boot (mesma loja do Termux)."
echo "  2. Na tela inicial, segure o dedo num espaco"
echo "     vazio > Widgets > Termux:Widget."
echo "  3. Abra o Termux:Boot uma vez (isso liga o"
echo "     inicio automatico)."
echo "  4. Toque em 'Iniciar Servidor' no widget."
echo ""
