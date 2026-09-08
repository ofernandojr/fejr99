#!/usr/bin/env node
/* ============================================================
   TVWEB Prompter — procura o servidor na rede local.

   Uso:  node scripts/achar-servidor.js [porta] [--diag]
   Saida: imprime a URL encontrada em stdout, sai com 0.
          Sai com 1 se nao achou. Com --diag, explica em stderr
          o que conseguiu descobrir da rede.

   Descobrir a rede no Android nao e garantido: a partir do
   Android 11 um app comum (o Termux e um) pode receber so o
   loopback de getifaddrs(), o que cega tanto o Node quanto o
   "ip addr". Por isso aqui as pistas vem de varias fontes e o
   modo --diag mostra quais funcionaram.
   ============================================================ */
const net = require('net');
const http = require('http');
const rede = require('./rede.js');

const PORTA = parseInt(process.argv[2], 10) || 8080;
const DIAG = process.argv.indexOf('--diag') !== -1;
const TIMEOUT_PORTA = 400;
const TIMEOUT_HTTP = 1500;
const PARALELO = 64;

const diag = (msg) => { if (DIAG) process.stderr.write('      ' + msg + '\n'); };
const base24 = (ip) => ip.split('.').slice(0, 3).join('.');

// ---------- monta a lista de enderecos a testar ----------
function alvos() {
  const lista = [];
  const vistos = new Set();
  const add = (ip) => {
    if (ip && rede.ehIPv4(ip) && !vistos.has(ip)) { vistos.add(ip); lista.push(ip); }
  };

  const p = rede.pistas();
  diag('interfaces pelo Node: ' + (p.node.length ? p.node.join(', ') : 'nenhuma'));
  diag('interfaces por ip/ifconfig: ' + (p.comandos.length ? p.comandos.join(', ') : 'nenhuma'));
  diag('gateway por /proc/net/route: ' + (p.gateways.length ? p.gateways.join(', ') : 'nenhum'));
  const doNode = p.node;
  const doCmd = p.comandos;
  const daRota = p.gateways;

  const meus = doNode.concat(doCmd).filter((ip) => ip !== '127.0.0.1');
  const bases = [];
  const addBase = (b) => { if (b && bases.indexOf(b) === -1) bases.push(b); };

  // Este aparelho tambem pode ser o servidor.
  add('127.0.0.1');
  meus.forEach(add);

  // O gateway primeiro: no hotspot, e o aparelho do servidor.
  daRota.forEach((ip) => { add(ip); addBase(base24(ip)); });

  meus.forEach((ip) => addBase(base24(ip)));
  ['192.168.43', '192.168.49', '192.168.1', '192.168.0'].forEach(addBase);

  bases.forEach((b) => add(b + '.1'));
  bases.forEach((b) => { for (let i = 1; i <= 254; i++) add(b + '.' + i); });

  diag('redes a varrer: ' + (bases.length ? bases.map((b) => b + '.x').join(', ') : 'nenhuma'));
  diag('total de enderecos a testar: ' + lista.length);
  return lista;
}

// ---------- testes ----------
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

// Porta aberta nao basta: confirma que quem respondeu e o app.
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
  if (!lista.length) {
    diag('nenhum endereco para testar - nao consegui enxergar a rede.');
    process.exit(1);
  }

  const abertosSemApp = [];
  for (let i = 0; i < lista.length; i += PARALELO) {
    const lote = lista.slice(i, i + PARALELO);
    const abertos = [];
    await Promise.all(lote.map(async (ip) => {
      if (await portaAberta(ip)) abertos.push(ip);
    }));
    for (const ip of lote) {
      if (abertos.indexOf(ip) === -1) continue;
      if (await ehPrompter(ip)) {
        console.log('http://' + ip + ':' + PORTA);
        process.exit(0);
      }
      abertosSemApp.push(ip);
    }
  }

  if (abertosSemApp.length) {
    diag('porta ' + PORTA + ' aberta, mas nao era o Prompter, em: ' + abertosSemApp.join(', '));
  } else {
    diag('nenhum aparelho respondeu na porta ' + PORTA + '.');
  }
  process.exit(1);
}

principal().catch((e) => { diag('erro: ' + (e && e.message)); process.exit(1); });
