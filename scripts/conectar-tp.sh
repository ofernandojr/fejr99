#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — Conectar ao servidor (aparelho de exibicao).
# Procura o servidor na rede e abre o navegador direto no app.

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"

clear
echo "=============================================="
echo "        TVWEB PROMPTER — CONECTAR"
echo "=============================================="
echo ""
echo "[..] Procurando o servidor na rede..."
echo "     (varre a rede inteira; leva uns segundos)"

# A busca e feita pelo Node: le as interfaces deste aparelho, varre a
# sub-rede em paralelo e confirma que quem respondeu e mesmo o Prompter.
# A versao antiga so testava 4 enderecos fixos e falhava em qualquer
# rede fora deles.
URL_ENCONTRADO=$(node "$PROJ/scripts/achar-servidor.js" "$PORTA" 2>/dev/null)

echo ""
echo "=============================================="
if [ -n "$URL_ENCONTRADO" ]; then
  echo "  SERVIDOR ENCONTRADO"
  echo "=============================================="
  echo ""
  echo "      >>>  $URL_ENCONTRADO  <<<"
  echo ""
  am start -a android.intent.action.VIEW -d "$URL_ENCONTRADO" >/dev/null 2>&1 || true
  echo "  Abrindo o navegador..."
  echo ""
  echo "  Se o app abrir e mostrar"
  echo "  'Conectado ao servidor', esta pronto."
else
  echo "  SERVIDOR NAO ENCONTRADO"
  echo "=============================================="
  echo ""
  echo "  Confira, na ordem:"
  echo ""
  echo "  1. No aparelho servidor, o atalho"
  echo "     'Iniciar Servidor' esta rodando?"
  echo "  2. O hotspot dele esta ligado?"
  echo "  3. Este aparelho esta conectado nesse"
  echo "     hotspot (ou na mesma Wi-Fi)?"
  echo ""
  echo "  Enderecos que ESTE aparelho enxerga:"
  ip -4 addr 2>/dev/null \
    | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print "      " $2}'
  echo ""
  echo "  Eles precisam comecar com os mesmos tres"
  echo "  numeros do endereco que o servidor mostrou."
  echo "  Se nao comecarem, os dois aparelhos estao"
  echo "  em redes diferentes."
  echo ""
  echo "  Ultimo recurso: olhe o endereco na tela do"
  echo "  'Iniciar Servidor' e digite no navegador."
fi
echo ""
echo "=============================================="
echo ""
echo "Pressione ENTER para fechar..."
read -r x
