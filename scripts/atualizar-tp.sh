#!/data/data/com.termux/files/usr/bin/sh
# TVWEB Prompter — baixa a versao mais nova do projeto.
# Derruba o servidor, atualiza os arquivos e avisa para religar.

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJ" || exit 1

clear
echo "=============================================="
echo "        TVWEB PROMPTER — ATUALIZAR"
echo "=============================================="
echo ""

echo "[..] Parando o servidor (se estiver rodando)..."
pkill -f "node server.js" 2>/dev/null || true

echo "[..] Baixando a versao nova..."
echo ""
if git pull --ff-only; then
  echo ""
  echo "=============================================="
  echo "  ATUALIZADO"
  echo "=============================================="
  echo ""
  echo "  Agora toque em 'Iniciar Servidor' para"
  echo "  subir o servidor de novo."
  echo ""
  echo "  Nos dois aparelhos, recarregue a pagina"
  echo "  do prompter (puxe a tela para baixo) para"
  echo "  pegar a versao nova."
else
  echo ""
  echo "=============================================="
  echo "  NAO DEU PARA ATUALIZAR"
  echo "=============================================="
  echo ""
  echo "  Motivo comum: arquivos alterados na mao"
  echo "  neste aparelho."
  echo ""
  echo "  Para descartar as alteracoes locais e"
  echo "  ficar igual ao GitHub, rode:"
  echo ""
  echo "    cd $PROJ"
  echo "    git fetch origin"
  echo "    git reset --hard origin/main"
  echo ""
  echo "  Atencao: isso apaga o que foi mudado aqui."
fi
echo ""
echo "=============================================="
echo ""
echo "Pressione ENTER para fechar..."
read -r x
