#!/usr/bin/env node
/* ============================================================
   TVWEB Prompter — desenha um QR Code no terminal.

   Uso:  node scripts/qr.js "http://192.168.43.1:8080"

   Reaproveita libs/qrcode.min.js, que o app ja usa no navegador.
   Assim o QR do Termux nao depende de instalar nenhum pacote —
   o "qrencode" nem existe no repositorio do Termux.
   ============================================================ */
const fs = require('fs');
const path = require('path');

const url = process.argv[2];
if (!url) {
  console.error('uso: node scripts/qr.js <url>');
  process.exit(1);
}

// Carrega a biblioteca do navegador num escopo isolado.
let qrcode;
try {
  const arquivo = path.join(__dirname, '..', 'libs', 'qrcode.min.js');
  const fonte = fs.readFileSync(arquivo, 'utf8');
  const janela = {};
  new Function('window', 'module', 'exports',
    fonte + ';if (typeof qrcode !== "undefined") window.qrcode = qrcode;'
  )(janela, {}, {});
  qrcode = janela.qrcode;
} catch (e) {
  process.exit(2);
}
if (typeof qrcode !== 'function') process.exit(2);

let qr;
try {
  qr = qrcode(0, 'M');
  qr.addData(url);
  qr.make();
} catch (e) {
  process.exit(3);
}

// Dois modulos por caractere usando os meio-blocos do Unicode: o QR sai
// com proporcao correta e cabe na largura do terminal do tablet.
const N = qr.getModuleCount();
const BORDA = 2;
const total = N + BORDA * 2;
const escuro = (l, c) => {
  if (l < BORDA || c < BORDA || l >= N + BORDA || c >= N + BORDA) return false;
  return qr.isDark(l - BORDA, c - BORDA);
};

const CHEIO = '██';   // dois modulos escuros empilhados
const CIMA  = '▀▀';   // escuro em cima, claro embaixo
const BAIXO = '▄▄';   // claro em cima, escuro embaixo
const VAZIO = '  ';

const linhas = [];
for (let l = 0; l < total; l += 2) {
  let linha = '  ';
  for (let c = 0; c < total; c++) {
    const a = escuro(l, c);
    const b = (l + 1 < total) ? escuro(l + 1, c) : false;
    linha += a && b ? CHEIO : a ? CIMA : b ? BAIXO : VAZIO;
  }
  linhas.push(linha);
}
console.log(linhas.join('\n'));
