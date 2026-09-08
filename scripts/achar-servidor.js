#!/usr/bin/env node
/* ============================================================
   TVWEB Prompter — procura o servidor na rede local.

   Uso:  node scripts/achar-servidor.js [porta]
   Saida: imprime a URL encontrada e sai com 0; sai com 1 se nao achou.

   A versao antiga testava so 4 enderecos fixos (192.168.43.1 e
   companhia) e falhava em qualquer rede fora desses. Aqui a
   sub-rede vem das interfaces deste proprio aparelho e e varrida
   inteira, em paralelo. Alem da porta, confere se quem respondeu
   e mesmo o Prompter — porta 8080 aberta pode ser outra coisa.
   ============================================================ */
const net = require('net');
const http = require('http');
const os = require('os');

const PORTA = parseInt(process.argv[2], 10) || 8080;
const TIMEOUT_PORTA = 400;   // ms por endereco no teste de porta
const TIMEOUT_HTTP = 1500;   // ms para confirmar que e o Prompter
const PARALELO = 64;

// ---- enderecos a testar ----
function alvos() {
  const lista = [];
  const vistos = new Set();
  const add = (ip) => { if (ip && !vistos.has(ip)) { vistos.add(ip); lista.push(ip); } };

  const redes = [];
  const ifaces = os.networkInterfaces();
  for (const nome of Object.keys(ifaces)) {
    for (const info of ifaces[nome] || []) {
      if (info.family !== 'IPv4' && info.family !== 4) continue;
      if (info.internal) continue;
      const partes = info.address.split('.');
      if (partes.length !== 4) continue;
      redes.push({ base: partes.slice(0, 3).join('.'), meu: info.address });
    }
  }

  // Este proprio aparelho pode ser o servidor (alguem rodando o
  // "Conectar Tp" na maquina que serve). Custa nada e evita falso negativo.
  add('127.0.0.1');
  for (const r of redes) add(r.meu);

  // Depois o gateway: costuma ser o aparelho que criou o hotspot.
  for (const r of redes) add(r.base + '.1');
  ['192.168.43.1', '192.168.49.1', '192.168.1.1', '192.168.0.1'].forEach(add);

  // Por fim, a sub-rede inteira de cada interface.
  for (const r of redes) {
    for (let i = 1; i <= 254; i++) add(r.base + '.' + i);
  }
  return lista;
}

function portaAberta(host) {
  return new Promise((ok) => {
    const s = net.connect({ host, port: PORTA });
    let pronto = false;
    const fim = (v) => { if (!pronto) { pronto = true; s.destroy(); ok(v); } };
    s.setTimeout(TIMEOUT_PORTA);
    s.on('connect', () => fim(true));
    s.on('timeout', () => fim(false));
    s.on('error', () => fim(false));
  });
}

// Porta aberta nao basta: confirma que a resposta e o app.
function ehPrompter(host) {
  return new Promise((ok) => {
    const req = http.get({ host, port: PORTA, path: '/', timeout: TIMEOUT_HTTP }, (res) => {
      let corpo = '';
      res.setEncoding('utf8');
      res.on('data', (p) => {
        corpo += p;
        if (corpo.length > 4000) { req.destroy(); ok(corpo.indexOf('TVWEB Prompter') !== -1); }
      });
      res.on('end', () => ok(corpo.indexOf('TVWEB Prompter') !== -1));
    });
    req.on('timeout', () => { req.destroy(); ok(false); });
    req.on('error', () => ok(false));
  });
}

async function principal() {
  const lista = alvos();
  for (let i = 0; i < lista.length; i += PARALELO) {
    const lote = lista.slice(i, i + PARALELO);
    const abertos = [];
    await Promise.all(lote.map(async (ip) => {
      if (await portaAberta(ip)) abertos.push(ip);
    }));
    // Testa os que responderam, na ordem original do lote.
    for (const ip of lote) {
      if (abertos.indexOf(ip) === -1) continue;
      if (await ehPrompter(ip)) {
        console.log('http://' + ip + ':' + PORTA);
        process.exit(0);
      }
    }
  }
  process.exit(1);
}

principal().catch(() => process.exit(1));
