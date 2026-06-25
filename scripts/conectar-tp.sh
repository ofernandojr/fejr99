#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — Conectar ao servidor (tablet de exibição)
# Tenta encontrar o servidor automaticamente e abre o navegador.

PORTA="${PORT:-8080}"
# IPs típicos do hotspot Android (gateway do tablet que criou o hotspot)
CANDIDATOS="192.168.43.1 192.168.49.1 192.168.1.1 192.168.0.1"

clear
echo "========================================"
echo "      TVWEB Prompter — Conectar"
echo "========================================"
echo ""
echo "[..] Procurando servidor na rede..."

URL_ENCONTRADO=""
for ip in $CANDIDATOS; do
  # Tenta conectar na porta do servidor (timeout 1s)
  if (echo "" | nc -w1 "$ip" "$PORTA") 2>/dev/null; then
    URL_ENCONTRADO="http://$ip:$PORTA"
    break
  fi
done

echo ""
echo "========================================"
if [ -n "$URL_ENCONTRADO" ]; then
  echo "  Servidor encontrado!"
  echo ""
  echo "  >>> $URL_ENCONTRADO <<<"
  echo ""
  # Abre o navegador direto no app
  am start -a android.intent.action.VIEW \
    -d "$URL_ENCONTRADO" 2>/dev/null || true
  echo "  Abrindo navegador..."
else
  echo "  Servidor nao encontrado."
  echo ""
  echo "  Verifique se:"
  echo "  - O hotspot do outro tablet esta ligado"
  echo "  - Este tablet esta conectado ao hotspot"
  echo "  - O servidor (Iniciar Tp) esta rodando"
  echo ""
  echo "  Ou abra manualmente o navegador em:"
  echo "  http://192.168.43.1:$PORTA"
fi
echo "========================================"
echo ""
echo "Pressione ENTER para fechar..."
read -r x
