/* ============================================================
   TVWEB Prompter — descoberta dos enderecos de rede.

   Usado pelo server.js (rota /ips, que alimenta o QR) e pelo
   achar-servidor.js. Fica num arquivo so porque as duas pontas
   sofrem do mesmo problema: a partir do Android 11 um app comum
   pode receber apenas o loopback de getifaddrs(), cegando tanto
   o os.networkInterfaces() do Node quanto o "ip addr". Entao as
   pistas vem de tres fontes e o que der certo vale.
   ============================================================ */
const os = require('os');
const fs = require('fs');
const { execSync } = require('child_process');

const ehIPv4 = (ip) => /^\d{1,3}(\.\d{1,3}){3}$/.test(ip);

function peloNode() {
  const achados = [];
  try {
    const ifaces = os.networkInterfaces();
    Object.keys(ifaces).forEach((nome) => {
      (ifaces[nome] || []).forEach((info) => {
        const v4 = info.family === 'IPv4' || info.family === 4;
        if (v4 && !info.internal && ehIPv4(info.address)) achados.push(info.address);
      });
    });
  } catch (e) { /* ignora */ }
  return achados;
}

function porComandos() {
  const achados = [];
  const rodar = (cmd) => {
    try {
      return execSync(cmd, { encoding: 'utf8', timeout: 4000, stdio: ['ignore', 'pipe', 'ignore'] });
    } catch (e) { return ''; }
  };
  const texto = rodar('ip -4 addr') + '\n' + rodar('ifconfig');
  const re = /(\d{1,3}(?:\.\d{1,3}){3})/g;
  let m;
  while ((m = re.exec(texto)) !== null) {
    const ip = m[1];
    if (ip === '127.0.0.1') continue;
    if (ip.startsWith('255.') || ip.endsWith('.255') || ip.endsWith('.0')) continue;
    achados.push(ip);
  }
  return achados;
}

// O gateway costuma ser o aparelho que criou o hotspot — ou seja, o
// servidor. Continua legivel mesmo quando getifaddrs() e bloqueado.
function peloProcRoute() {
  const achados = [];
  try {
    const linhas = fs.readFileSync('/proc/net/route', 'utf8').split('\n').slice(1);
    for (const linha of linhas) {
      const col = linha.trim().split(/\s+/);
      if (col.length < 3) continue;
      const hexParaIp = (hex) => {
        const n = parseInt(hex, 16);
        if (!isFinite(n) || n === 0) return null;
        return [n & 255, (n >> 8) & 255, (n >> 16) & 255, (n >> 24) & 255].join('.');
      };
      const gw = hexParaIp(col[2]);
      if (gw && ehIPv4(gw)) achados.push(gw);
    }
  } catch (e) { /* ignora */ }
  return achados;
}

function unico(lista) {
  const vistos = new Set();
  return lista.filter((ip) => {
    if (!ip || vistos.has(ip)) return false;
    vistos.add(ip);
    return true;
  });
}

// Enderecos DESTE aparelho (para montar o QR e para dizer onde ele esta).
function meusEnderecos() {
  return unico(pelosDois());
}
function pelosDois() {
  return peloNode().concat(porComandos());
}

// Tudo que ajuda a localizar o servidor, com as fontes separadas para
// quem quiser mostrar um diagnostico.
function pistas() {
  return {
    node: unico(peloNode()),
    comandos: unico(porComandos()),
    gateways: unico(peloProcRoute())
  };
}

module.exports = { meusEnderecos, pistas, ehIPv4 };
