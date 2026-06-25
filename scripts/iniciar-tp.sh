#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — script principal
# Ativado pelo atalho "Iniciar Tp" (Termux:Widget) ou pelo boot automático.
# O que faz:
#   1. Sobe o servidor (se não estiver rodando)
#   2. Liga o hotspot do tablet
#   3. Mostra o IP para o outro tablet conectar

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"

# ============================================================
# 1. WAKE LOCK — impede o Android de suspender o processo
# ============================================================
termux-wake-lock 2>/dev/null

# ============================================================
# 2. SERVIDOR — sobe se ainda não estiver rodando na porta
# ============================================================
servidor_rodando() {
  # tenta conectar na porta; se conseguir, já está no ar
  (echo "" | nc -w1 127.0.0.1 "$PORTA") 2>/dev/null && return 0 || return 1
}

if servidor_rodando; then
  echo "[Servidor] Já está rodando na porta $PORTA."
else
  echo "[Servidor] Iniciando na porta $PORTA..."
  cd "$PROJ" || exit 1
  node server.js > "$PROJ/server.log" 2>&1 &
  SRV_PID=$!
  # aguarda o servidor aceitar conexões (até 8s)
  i=0
  while [ $i -lt 8 ]; do
    servidor_rodando && break
    sleep 1
    i=$((i+1))
  done
  if servidor_rodando; then
    echo "[Servidor] Iniciado (PID $SRV_PID)."
  else
    echo "[Servidor] AVISO: servidor ainda não respondeu. Veja $PROJ/server.log"
  fi
fi

# ============================================================
# 3. HOTSPOT — tenta ativar e aguarda a interface subir
# ============================================================
echo "[Hotspot] Ligando..."

# Android 12+ / alguns ROMs: ativar via cmd connectivity
HOTSPOT_CMD_OK=0
if command -v cmd >/dev/null 2>&1; then
  cmd connectivity tethering start wifi 2>/dev/null && HOTSPOT_CMD_OK=1
fi

# Fallback: abre as configurações de hotspot (o usuário liga em 1 toque)
if [ "$HOTSPOT_CMD_OK" -eq 0 ]; then
  echo "[Hotspot] Abrindo configurações — ligue o hotspot e volte aqui."
  am start -a android.intent.action.MAIN \
    -n com.android.settings/.TetherSettings 2>/dev/null || true
fi

# Aguarda a interface do hotspot aparecer (até 10s)
echo "[Hotspot] Aguardando interface subir..."
IP=""
i=0
while [ $i -lt 10 ]; do
  sleep 1
  # Procura a interface do hotspot: wlan1, ap0, swlan0, etc.
  IP=$(ip -4 addr 2>/dev/null | awk '
    /^[0-9]+: (wlan1|ap0|swlan0|wlan0:hotspot|rndis)/ { iface=1 }
    iface && /inet / { match($0, /inet ([0-9.]+)/, a); if(a[1]!="") print a[1]; iface=0 }
  ' | head -1)
  # Tenta também pela rota padrão do hotspot Android (costuma ser 192.168.43.x)
  if [ -z "$IP" ]; then
    IP=$(ip -4 addr 2>/dev/null | awk '/inet 192\.168\.(43|49)\.[0-9]+/ {gsub(/\/.*/, "", $2); print $2}' | head -1)
  fi
  [ -n "$IP" ] && break
  i=$((i+1))
done

# ============================================================
# 4. RESULTADO — exibe o endereço para o outro tablet
# ============================================================
echo ""
echo "========================================"
if [ -n "$IP" ]; then
  URL="http://$IP:$PORTA"
  echo "  TVWEB Prompter — PRONTO!"
  echo ""
  echo "  No outro tablet, abra:"
  echo ""
  echo "  >>> $URL <<<"
  echo ""
  echo "  (Este tablet usa: http://localhost:$PORTA)"
  echo "========================================"

  # Notificação do Android com o endereço (se termux-api instalado)
  termux-notification \
    --title "TVWEB Prompter rodando" \
    --content "Outro tablet: $URL" \
    --priority high \
    --ongoing 2>/dev/null || true
else
  echo "  Servidor OK — hotspot não detectado."
  echo ""
  echo "  Após ligar o hotspot, abra no outro tablet:"
  echo "  http://<IP-deste-tablet>:$PORTA"
  echo ""
  echo "  Para achar o IP: rode  ip addr  no Termux."
  echo "========================================"

  termux-notification \
    --title "TVWEB Prompter" \
    --content "Ligue o hotspot e rode: ip addr" \
    --priority high 2>/dev/null || true
fi
