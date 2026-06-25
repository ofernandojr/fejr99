#!/data/data/com.termux/files/usr/bin/sh
PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"

clear
echo "========================================"
echo "         TVWEB Prompter"
echo "========================================"
echo ""

termux-wake-lock 2>/dev/null

# Sobe o servidor se não estiver rodando
servidor_rodando() {
  (echo "" | nc -w1 127.0.0.1 "$PORTA") 2>/dev/null && return 0 || return 1
}

if servidor_rodando; then
  echo "[OK] Servidor ja rodando na porta $PORTA."
else
  echo "[..] Iniciando servidor..."
  cd "$PROJ" || exit 1
  node server.js > "$PROJ/server.log" 2>&1 &
  i=0
  while [ $i -lt 10 ]; do
    servidor_rodando && break
    sleep 1; i=$((i+1))
  done
  servidor_rodando && echo "[OK] Servidor iniciado." \
    || { echo "[ERRO] Servidor nao respondeu. Veja $PROJ/server.log"; read -r x; exit 1; }
fi

# Pega todos os IPs disponíveis
IPS=$(ip -4 addr 2>/dev/null \
  | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print $2}')

echo ""
echo "========================================"
echo "  Neste tablet:  http://localhost:$PORTA"
echo ""
if [ -n "$IPS" ]; then
  echo "  Outro tablet:"
  echo "$IPS" | while read -r ip; do
    echo "    >>> http://$ip:$PORTA <<<"
  done
else
  echo "  Ligue o Hotspot e rode este script"
  echo "  novamente para ver o IP do outro tablet."
fi
echo "========================================"
echo ""
echo "Pressione ENTER para fechar..."
read -r x
