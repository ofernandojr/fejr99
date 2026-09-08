#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — sobe o servidor neste aparelho e mostra o passo a passo
# de como ligar o outro aparelho nele.
# IMPORTANTE: esta janela precisa ficar aberta. Fechar = servidor cai.
PROJ="$(cd "$(dirname "$0")/.." && pwd)"
PORTA="${PORT:-8080}"

clear
echo "=============================================="
echo "        TVWEB PROMPTER — SERVIDOR"
echo "=============================================="
echo ""

termux-wake-lock 2>/dev/null

servidor_rodando() {
  (echo "" | nc -w1 127.0.0.1 "$PORTA") 2>/dev/null && return 0 || return 1
}

if servidor_rodando; then
  echo "[OK] O servidor ja estava rodando."
  JA_RODAVA=1
else
  echo "[..] Ligando o servidor..."
  cd "$PROJ" || exit 1
  node server.js > "$PROJ/server.log" 2>&1 &
  i=0
  while [ $i -lt 10 ]; do
    servidor_rodando && break
    sleep 1; i=$((i+1))
  done
  if servidor_rodando; then
    echo "[OK] Servidor ligado."
    JA_RODAVA=0
  else
    echo ""
    echo "[ERRO] O servidor nao subiu."
    echo ""
    echo "  Tente, nesta ordem:"
    echo "  1. Feche e toque em 'Iniciar Servidor' de novo."
    echo "  2. Rode o atalho 'Atualizar Tp'."
    echo "  3. Veja o motivo em:"
    echo "     $PROJ/server.log"
    echo ""
    echo "Pressione ENTER para fechar..."
    read -r x
    exit 1
  fi
fi

# Descobre os IPs deste aparelho (o outro aparelho usa um deles)
IPS=$(ip -4 addr 2>/dev/null \
  | awk '/inet / && !/127\.0\.0\.1/ {gsub(/\/.*/, "", $2); print $2}')
if [ -z "$IPS" ]; then
  IPS=$(ifconfig 2>/dev/null \
    | awk '/inet / && !/127\.0\.0\.1/ {
        for(i=1;i<=NF;i++) if($i~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $i!="127.0.0.1") print $i
      }')
fi

echo ""
echo "=============================================="
echo "  COMO LIGAR UM APARELHO NO OUTRO"
echo "=============================================="
echo ""
echo "  PASSO 1 — Ligue o hotspot DESTE aparelho"
echo "  ----------------------------------------"
echo "    Configuracoes > Ponto de acesso (hotspot)"
echo "    Nao precisa de internet: o hotspot serve"
echo "    so para os dois se enxergarem."
echo "    (Ou coloque os dois na mesma Wi-Fi.)"
echo ""
echo "  PASSO 2 — Conecte o OUTRO aparelho"
echo "  ----------------------------------------"
echo "    No outro aparelho, entre no Wi-Fi e"
echo "    conecte no hotspot que voce acabou de"
echo "    ligar."
echo ""
echo "  PASSO 3 — Abra o app NESTE aparelho"
echo "  ----------------------------------------"
echo "    Abra o navegador e digite:"
echo ""
echo "        http://localhost:$PORTA"
echo ""
echo "  PASSO 4 — Abra o app no OUTRO aparelho"
echo "  ----------------------------------------"
if [ -n "$IPS" ]; then
  echo "    Abra o navegador dele e digite:"
  echo ""
  echo "$IPS" | while read -r ip; do
    echo "        >>>  http://$ip:$PORTA  <<<"
  done
  echo ""
  echo "    (Se aparecer mais de um endereco acima,"
  echo "     teste de cima para baixo ate um abrir.)"
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
echo "  PASSO 5 — Confira"
echo "  ----------------------------------------"
echo "    No topo do app, nos dois aparelhos, deve"
echo "    aparecer: 'Conectado ao servidor'."
echo "    Pronto — o que voce mudar em um aparece"
echo "    no outro na hora."
echo ""
echo "    Dica: no menu do navegador use"
echo "    'Adicionar a tela inicial' nos dois."
echo ""
echo "=============================================="
echo "  DEIXE ESTA JANELA ABERTA"
echo "=============================================="
echo ""
echo "  Fechar esta janela DERRUBA o servidor e os"
echo "  aparelhos param de sincronizar."
echo ""
echo "  Pode voltar para a tela inicial normalmente:"
echo "  o servidor continua rodando por tras."
echo ""
echo "  Para DESLIGAR o servidor de proposito:"
echo "  volte aqui e pressione Ctrl + C."
echo ""

# Mantém a sessão viva sem pedir ENTER: fechar aqui derrubaria o servidor.
if [ "$JA_RODAVA" = "1" ]; then
  # Servidor é de outra sessão; só segura a tela para leitura.
  while true; do sleep 3600; done
else
  wait
fi
