#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — Conectar ao servidor (aparelho de exibicao).
# Procura o servidor na rede e abre o navegador direto no app.

PORTA="${PORT:-8080}"
# IPs tipicos do hotspot/roteador Android
CANDIDATOS="192.168.43.1 192.168.49.1 192.168.1.1 192.168.0.1"

clear
echo "=============================================="
echo "        TVWEB PROMPTER — CONECTAR"
echo "=============================================="
echo ""
echo "[..] Procurando o servidor na rede..."

URL_ENCONTRADO=""
for ip in $CANDIDATOS; do
  if (echo "" | nc -w1 "$ip" "$PORTA") 2>/dev/null; then
    URL_ENCONTRADO="http://$ip:$PORTA"
    break
  fi
done

echo ""
echo "=============================================="
if [ -n "$URL_ENCONTRADO" ]; then
  echo "  SERVIDOR ENCONTRADO"
  echo "=============================================="
  echo ""
  echo "      >>>  $URL_ENCONTRADO  <<<"
  echo ""
  am start -a android.intent.action.VIEW -d "$URL_ENCONTRADO" 2>/dev/null || true
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
  echo "  Nao achou mesmo? Olhe o endereco que a"
  echo "  tela do 'Iniciar Servidor' mostra e digite"
  echo "  ele no navegador deste aparelho."
fi
echo ""
echo "=============================================="
echo ""
echo "Pressione ENTER para fechar..."
read -r x
