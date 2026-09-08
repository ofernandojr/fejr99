#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — Conectar ao servidor (aparelho de exibicao).
# Procura o servidor na rede e abre o navegador direto no app.

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"
BUSCA="$PROJ/scripts/achar-servidor.js"

clear
echo "=============================================="
echo "        TVWEB PROMPTER — CONECTAR"
echo "=============================================="
echo ""

# ---- checagens que antes falhavam em silencio ----
if ! command -v node >/dev/null 2>&1; then
  echo "  [ERRO] O Node nao esta instalado NESTE"
  echo "         aparelho. Rode:"
  echo ""
  echo "         pkg install nodejs"
  echo ""
  echo "Pressione ENTER para fechar..."
  read -r x
  exit 1
fi

if [ ! -f "$BUSCA" ]; then
  echo "  [ERRO] Este aparelho esta com uma versao"
  echo "         antiga do projeto."
  echo ""
  echo "         Toque em 'Atualizar Tp' e depois"
  echo "         tente de novo."
  echo ""
  echo "         (Cada aparelho tem a sua propria"
  echo "          copia: atualizar um nao atualiza"
  echo "          o outro.)"
  echo ""
  echo "Pressione ENTER para fechar..."
  read -r x
  exit 1
fi

echo "[..] Procurando o servidor na rede..."
echo ""

# O --diag imprime em stderr o que ele conseguiu descobrir da rede.
# Fica visivel de proposito: se falhar, da para ver o porque.
URL_ENCONTRADO=$(node "$BUSCA" "$PORTA" --diag)

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
  echo "  Olhe as linhas acima: elas dizem quais"
  echo "  redes este aparelho conseguiu enxergar."
  echo ""
  echo "  Se disserem 'nenhuma', o Android nao deixou"
  echo "  o Termux ler a rede. Nesse caso digite o"
  echo "  endereco a mao (passo abaixo)."
  echo ""
  echo "  Confira tambem:"
  echo "  1. No aparelho servidor, o 'Iniciar"
  echo "     Servidor' esta rodando?"
  echo "  2. O hotspot dele esta ligado?"
  echo "  3. Este aparelho esta conectado nesse"
  echo "     hotspot (ou na mesma Wi-Fi)?"
  echo ""
  echo "  SEMPRE FUNCIONA: olhe o endereco na tela"
  echo "  do 'Iniciar Servidor' (ou aponte a camera"
  echo "  para o QR que ele mostra) e abra no"
  echo "  navegador deste aparelho."
fi
echo ""
echo "=============================================="
echo ""
echo "Pressione ENTER para fechar..."
read -r x
