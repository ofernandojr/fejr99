#!/data/data/com.termux/files/usr/bin/sh
# Sobe o servidor do TVWEB Prompter no Termux.
# Usado pelo atalho (Termux:Widget) e pelo início automático (Termux:Boot).

# Impede o Android de suspender o processo enquanto o servidor roda.
termux-wake-lock 2>/dev/null

# Vai para a pasta do projeto (ajuste se o seu caminho for outro).
cd "$HOME/fejr99" 2>/dev/null || cd "$(dirname "$0")/.." || exit 1

# Inicia o servidor (porta padrão 8080).
exec node server.js
