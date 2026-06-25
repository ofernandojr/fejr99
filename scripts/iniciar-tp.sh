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
# 3. HOTSPOT — abre as configurações para ligar manualmente
#    (ativar hotspot via comando requer permissão de root/ADB)
# ============================================================
echo ""
echo "[..] Abrindo configuracoes de hotspot..."
echo "     Ligue o Hotspot e volte ao Termux."
echo ""
am start -a android.intent.action.MAIN \
  -n com.android.settings/.TetherSettings 2>/dev/null \
  || am start -a android.settings.WIRELESS_SETTINGS 2>/dev/null \
  || echo "     (Abra manualmente: Configuracoes > Hotspot)"

# Aguarda o usuário ligar o hotspot (até 30s), mostrando contagem
echo "[..] Aguardando hotspot (30s)..."
IP=""
i=0
while [ $i -lt 30 ]; do
  sleep 1
  i=$((i+1))

  # Pega todos os IPs não-loopback disponíveis
  TODOS_IPS=$(ip -4 addr 2>/dev/null \
    | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print $2}')

  # Prefere o range típico do hotspot Android (192.168.43.x ou 192.168.49.x)
  IP=$(echo "$TODOS_IPS" | grep -E '^192\.168\.(43|49)\.' | head -1)

  # Fallback: qualquer IP que não seja loopback e não seja de rede cabeada (10.x)
  if [ -z "$IP" ]; then
    IP=$(echo "$TODOS_IPS" | grep -v '^10\.' | head -1)
  fi

  # Qualquer IP como último recurso
  if [ -z "$IP" ]; then
    IP=$(echo "$TODOS_IPS" | head -1)
  fi

  [ -n "$IP" ] && break
  printf "\r     %ds..." "$((30 - i))"
done
echo ""

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
