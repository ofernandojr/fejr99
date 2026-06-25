#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — script principal
# Ativado pelo atalho "Iniciar Tp" (Termux:Widget) ou pelo boot automático.

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"

clear
echo "========================================"
echo "         TVWEB Prompter"
echo "========================================"
echo ""

# ============================================================
# 1. WAKE LOCK
# ============================================================
termux-wake-lock 2>/dev/null

# ============================================================
# 2. SERVIDOR
# ============================================================
servidor_rodando() {
  (echo "" | nc -w1 127.0.0.1 "$PORTA") 2>/dev/null && return 0 || return 1
}

if servidor_rodando; then
  echo "[OK] Servidor ja esta rodando na porta $PORTA."
else
  echo "[..] Iniciando servidor..."
  cd "$PROJ" || { echo "[ERRO] Pasta nao encontrada: $PROJ"; read -r dummy; exit 1; }
  node server.js > "$PROJ/server.log" 2>&1 &
  SRV_PID=$!
  i=0
  while [ $i -lt 10 ]; do
    servidor_rodando && break
    sleep 1
    i=$((i+1))
  done
  if servidor_rodando; then
    echo "[OK] Servidor iniciado."
  else
    echo "[ERRO] Servidor nao respondeu. Veja $PROJ/server.log"
    echo ""; cat "$PROJ/server.log" 2>/dev/null | tail -10
    echo ""; echo "Pressione ENTER para fechar..."
    read -r dummy; exit 1
  fi
fi

# ============================================================
# 3. HOTSPOT — abre configurações e espera o usuário ligar
# ============================================================
echo ""
echo "[..] Abrindo configuracoes de hotspot..."
am start -a android.intent.action.MAIN \
  -n com.android.settings/.TetherSettings 2>/dev/null \
  || am start -a android.settings.WIRELESS_SETTINGS 2>/dev/null \
  || echo "     (Abra manualmente: Configuracoes > Hotspot)"

echo ""
echo "  1. Ligue o Hotspot nas configuracoes"
echo "  2. Volte ao Termux"
echo "  3. Pressione ENTER"
echo ""
read -r dummy

# Detecta o IP após o usuário confirmar
IP=""
# Tenta até 5x com intervalo de 1s (interface pode demorar 1-2s pra aparecer)
i=0
while [ $i -lt 5 ]; do
  TODOS=$(ip -4 addr 2>/dev/null \
    | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print $2}')
  IP=$(echo "$TODOS" | grep -E '^192\.168\.(43|49)\.' | head -1)
  [ -z "$IP" ] && IP=$(echo "$TODOS" | grep -v '^10\.' | head -1)
  [ -z "$IP" ] && IP=$(echo "$TODOS" | head -1)
  [ -n "$IP" ] && break
  sleep 1
  i=$((i+1))
done

# ============================================================
# 4. RESULTADO
# ============================================================
echo ""
echo "========================================"
if [ -n "$IP" ]; then
  URL="http://$IP:$PORTA"
  echo "  PRONTO!"
  echo ""
  echo "  Neste tablet:   http://localhost:$PORTA"
  echo ""
  echo "  Outro tablet:"
  echo ""
  echo "    >>> $URL <<<"
  echo ""
  echo "========================================"

  termux-notification \
    --title "TVWEB Prompter rodando" \
    --content "Outro tablet: $URL" \
    --priority high \
    --ongoing 2>/dev/null || true
else
  # Mostra todos os IPs disponíveis para o usuário escolher
  echo "  Servidor OK."
  echo ""
  echo "  Hotspot nao detectado automaticamente."
  echo "  Use um dos IPs abaixo no outro tablet:"
  echo ""
  ip -4 addr 2>/dev/null \
    | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print "    http://" $2 ":'$PORTA'"}'
  echo ""
  echo "  (Se nenhum funcionar, verifique se o"
  echo "   hotspot esta ligado e tente de novo.)"
  echo "========================================"
fi

# Mantém o terminal aberto — sem isso o Termux:Widget fecha na hora
echo ""
echo "Pressione ENTER para fechar..."
read -r dummy
