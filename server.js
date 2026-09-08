/* ============================================================
   TVWEB Prompter — Servidor local (sem dependências)
   ------------------------------------------------------------
   Roda em um dos tablets (ex.: via Termux com Node.js) e:
     - serve o app (index.html, libs/, etc.)
     - mantém o estado compartilhado (pauta, ajustes, controles)
     - sincroniza em tempo real via SSE (Server-Sent Events)
   Os dois tablets só precisam abrir o endereço do servidor no
   navegador, na mesma Wi-Fi ou no hotspot deste aparelho.
   Não precisa de internet (só uma rede local entre eles).

   Como rodar:
     node server.js            (porta padrão 8080)
     PORT=3000 node server.js  (outra porta)
   ============================================================ */
const http = require('http');
const fs = require('fs');
const path = require('path');
const rede = require('./scripts/rede.js');

const PORT = process.env.PORT || 8080;
const ROOT = __dirname;

// Estado compartilhado entre todos os tablets conectados
const estado = { pauta: null, settings: null, live: null };
// Clientes SSE conectados
let clientes = [];

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon'
};

function broadcast(obj) {
  const linha = 'data: ' + JSON.stringify(obj) + '\n\n';
  clientes.forEach((res) => { try { res.write(linha); } catch (e) {} });
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://local');

  // CORS liberado (permite até o app do Netlify falar com este servidor)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') { res.writeHead(204); return res.end(); }

  // ----- Enderecos de rede deste servidor -----
  // O navegador nao tem como descobrir o IP da maquina. Quando o app e
  // aberto por "localhost", e daqui que ele tira o endereco de verdade
  // para montar o QR que o outro aparelho vai ler.
  if (url.pathname === '/ips') {
    const ips = rede.meusEnderecos();
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    return res.end(JSON.stringify({ ips: ips, porta: PORT }));
  }

  // ----- Stream de eventos (servidor -> clientes) -----
  if (url.pathname === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    });
    res.write('retry: 1000\n\n');
    clientes.push(res);
    // envia o estado atual para o recém-chegado
    ['pauta', 'settings', 'live'].forEach((k) => {
      if (estado[k] !== null) res.write('data: ' + JSON.stringify({ kind: k, data: estado[k], by: 'server' }) + '\n\n');
    });
    req.on('close', () => { clientes = clientes.filter((c) => c !== res); });
    return;
  }

  // ----- Atualização (cliente -> servidor -> todos) -----
  if (url.pathname === '/update' && req.method === 'POST') {
    let body = '';
    req.on('data', (c) => { body += c; if (body.length > 4e6) req.destroy(); });
    req.on('end', () => {
      try {
        const msg = JSON.parse(body);
        if (['pauta', 'settings', 'live'].includes(msg.kind)) {
          estado[msg.kind] = msg.data;
          broadcast(msg);
        }
        res.writeHead(200); res.end('ok');
      } catch (e) { res.writeHead(400); res.end('bad'); }
    });
    return;
  }

  // ----- Arquivos estáticos (o próprio app) -----
  let p = url.pathname === '/' ? '/index.html' : decodeURIComponent(url.pathname);
  const seguro = path.normalize(p).replace(/^(\.\.[/\\])+/, '');
  const arquivo = path.join(ROOT, seguro);
  if (!arquivo.startsWith(ROOT)) { res.writeHead(403); return res.end('forbidden'); }
  fs.readFile(arquivo, (err, data) => {
    if (err) { res.writeHead(404); return res.end('não encontrado'); }
    res.writeHead(200, { 'Content-Type': MIME[path.extname(arquivo)] || 'application/octet-stream' });
    res.end(data);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log('TVWEB Prompter — servidor local rodando.');
  console.log('Neste tablet, abra:  http://localhost:' + PORT);
  console.log('No outro tablet (mesma Wi-Fi/hotspot), abra:  http://<IP-deste-tablet>:' + PORT);
});
