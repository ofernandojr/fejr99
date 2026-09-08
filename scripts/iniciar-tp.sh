#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — sobe o servidor neste aparelho e abre o app.
#
# Primeira vez: liga o servidor, mostra o passo a passo e SEGURA a janela
#   aberta (fechar derruba o servidor, que e filho desta sessao).
# Tocar de novo com o servidor ja rodando: so reabre o app e fecha. Nao
#   reinicia nada — o servidor e de outra sessao e nao depende desta.
PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"
LOCAL="http://localhost:$PORTA"

# Testa se uma porta responde. Usa o proprio Node (que ja e obrigatorio
# para o servidor) em vez do "nc": um pacote a menos para instalar, e sem
# o risco de a deteccao falhar em silencio quando o netcat nao existe.
porta_aberta() {  # $1=host  $2=porta
  node -e '
    const s = require("net").connect({ host: process.argv[1], port: +process.argv[2] });
    s.setTimeout(1000);
    s.on("connect", () => { s.destroy(); process.exit(0); });
    s.on("timeout", () => { s.destroy(); process.exit(1); });
    s.on("error",   () => process.exit(1));
  ' "$1" "$2" 2>/dev/null
}

servidor_rodando() {
  porta_aberta 127.0.0.1 "$PORTA"
}

abrir_app() {
  am start -a android.intent.action.VIEW -d "$LOCAL" >/dev/null 2>&1 || true
}

# Descobre os IPs deste aparelho (o outro aparelho usa um deles)
descobrir_ips() {
  IPS=$(ip -4 addr 2>/dev/null \
    | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print $2}')
  if [ -z "$IPS" ]; then
    IPS=$(ifconfig 2>/dev/null \
      | awk '/inet / && !/127\.0\.0\.1/ {
          for(i=1;i<=NF;i++) if($i~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $i!="127.0.0.1") print $i
        }')
  fi
}

mostrar_qr() {
  # $1 = url
  if command -v qrencode >/dev/null 2>&1; then
    echo ""
    qrencode -t ANSIUTF8 -m 2 "$1"
    echo "    $1"
  else
    echo ""
    echo "    Para ver um QR Code aqui, instale uma"
    echo "    vez:   pkg install qrencode"
  fi
}

clear

# ============================================================
#  JA ESTAVA RODANDO — so reabre o app e sai
# ============================================================
if servidor_rodando; then
  descobrir_ips
  echo "=============================================="
  echo "        TVWEB PROMPTER"
  echo "=============================================="
  echo ""
  echo "  [OK] O servidor ja esta rodando."
  echo "       Reabrindo o app..."
  echo ""
  if [ -n "$IPS" ]; then
    echo "  No outro aparelho:"
    echo "$IPS" | while read -r ip; do
      echo "      http://$ip:$PORTA"
    done
    mostrar_qr "http://$(echo "$IPS" | head -n 1):$PORTA"
  fi
  echo ""
  echo "=============================================="
  abrir_app
  exit 0
fi

# ============================================================
#  PRIMEIRA VEZ — liga o servidor
# ============================================================
echo "=============================================="
echo "        TVWEB PROMPTER — SERVIDOR"
echo "=============================================="
echo ""

termux-wake-lock 2>/dev/null

echo "[..] Ligando o servidor..."
cd "$PROJ" || exit 1
node server.js > "$PROJ/server.log" 2>&1 &
i=0
while [ $i -lt 10 ]; do
  servidor_rodando && break
  sleep 1; i=$((i+1))
done

if ! servidor_rodando; then
  echo ""
  echo "[ERRO] O servidor nao subiu."
  echo ""
  echo "  Tente, nesta ordem:"
  echo "  1. Feche e toque em 'Iniciar Servidor' de novo."
  echo "  2. Rode o atalho 'Atualizar Tp'."
  if grep -q EADDRINUSE "$PROJ/server.log" 2>/dev/null; then
    echo "  OBS: a porta $PORTA ja esta ocupada por"
    echo "       outro programa. Feche-o, ou rode"
    echo "       com outra porta:"
    echo "         PORT=8081 sh scripts/iniciar-tp.sh"
    echo ""
  fi
  echo "  3. Veja o motivo em:"
  echo "     $PROJ/server.log"
  echo ""
  echo "Pressione ENTER para fechar..."
  read -r x
  exit 1
fi

echo "[OK] Servidor ligado."
descobrir_ips
abrir_app

echo ""
echo "=============================================="
echo "  COMO LIGAR UM APARELHO NO OUTRO"
echo "=============================================="
echo ""
echo "  PASSO 1 - Ligue o hotspot DESTE aparelho"
echo "  ----------------------------------------"
echo "    Configuracoes > Ponto de acesso (hotspot)"
echo "    Nao precisa de internet: o hotspot serve"
echo "    so para os dois se enxergarem."
echo "    (Ou coloque os dois na mesma Wi-Fi.)"
echo ""
echo "  PASSO 2 - Conecte o OUTRO aparelho"
echo "  ----------------------------------------"
echo "    No outro aparelho, entre no Wi-Fi e"
echo "    conecte no hotspot que voce acabou de"
echo "    ligar."
echo ""
echo "  PASSO 3 - Neste aparelho"
echo "  ----------------------------------------"
echo "    O app ja foi aberto no navegador."
echo "    Se nao abriu, digite:  $LOCAL"
echo ""
echo "  PASSO 4 - Abra o app no OUTRO aparelho"
echo "  ----------------------------------------"
if [ -n "$IPS" ]; then
  echo "    Aponte a camera dele para o QR abaixo,"
  echo "    ou digite o endereco no navegador:"
  echo ""
  echo "$IPS" | while read -r ip; do
    echo "        >>>  http://$ip:$PORTA  <<<"
  done
  echo ""
  echo "    (Se aparecer mais de um endereco acima,"
  echo "     teste de cima para baixo ate um abrir.)"
  mostrar_qr "http://$(echo "$IPS" | head -n 1):$PORTA"
  echo ""
  echo "    Atalho: no outro aparelho da para usar o"
  echo "    widget 'Conectar Tp', que procura sozinho."
else
  echo "    NENHUMA REDE DETECTADA."
  echo ""
  echo "    Ligue o hotspot (Passo 1) e toque em"
  echo "    'Iniciar Servidor' de novo para o"
  echo "    endereco aparecer aqui."
fi
echo ""
echo "  PASSO 5 - Confira"
echo "  ----------------------------------------"
echo "    No topo do app, nos dois aparelhos, deve"
echo "    aparecer: 'Conectado ao servidor'."
echo "    Pronto - o que voce mudar em um aparece"
echo "    no outro na hora."
echo ""
echo "=============================================="
echo "  DEIXE ESTA JANELA ABERTA"
echo "=============================================="
echo ""
echo "  Fechar esta janela DERRUBA o servidor."
echo ""
echo "  Pode voltar para a tela inicial normalmente:"
echo "  o servidor continua rodando por tras. Tocar"
echo "  em 'Iniciar Servidor' de novo so reabre o"
echo "  app, sem reiniciar nada."
echo ""
echo "  Para DESLIGAR o servidor de proposito:"
echo "  volte aqui e pressione Ctrl + C."
echo ""

# Segura a sessao: o servidor e filho dela e cairia junto.
wait
