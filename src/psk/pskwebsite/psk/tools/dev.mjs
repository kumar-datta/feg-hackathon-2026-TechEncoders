#!/usr/bin/env node
/**
 * dev.js — starts the API and the Vite client together.
 *
 *   npm run dev
 *
 * Exists because running only the client produces a wall of
 * "http proxy error ... ECONNREFUSED" messages that look like a code bug but
 * really just mean the API on port 5000 is not running.
 *
 * No extra dependencies: it just spawns the two npm scripts and forwards
 * their output with a prefix.
 */
import { spawn } from 'node:child_process';
import net from 'node:net';

const NPM = process.platform === 'win32' ? 'npm.cmd' : 'npm';

const COLOURS = { api: '\x1b[36m', web: '\x1b[35m', warn: '\x1b[33m', dim: '\x1b[90m', off: '\x1b[0m' };

function log(tag, line) {
  const colour = COLOURS[tag] || '';
  process.stdout.write(`${colour}[${tag}]${COLOURS.off} ${line}\n`);
}

/** Resolve true if something is already listening on the port. */
function portInUse(port) {
  return new Promise((resolve) => {
    const socket = net.connect({ host: '127.0.0.1', port });
    const done = (result) => { socket.destroy(); resolve(result); };
    socket.setTimeout(800);
    socket.on('connect', () => done(true));
    socket.on('timeout', () => done(false));
    socket.on('error', () => done(false));
  });
}

function run(tag, args) {
  const child = spawn(NPM, args, { cwd: process.cwd(), shell: process.platform === 'win32' });

  const pipe = (stream) => {
    let buffer = '';
    stream.on('data', (chunk) => {
      buffer += chunk.toString();
      const lines = buffer.split('\n');
      buffer = lines.pop();
      for (const line of lines) if (line.trim()) log(tag, line);
    });
  };

  pipe(child.stdout);
  pipe(child.stderr);

  child.on('exit', (code) => {
    if (code !== 0) log('warn', `${tag} exited with code ${code}`);
  });

  return child;
}

async function main() {
  if (!(await portInUse(27017))) {
    log('warn', 'MongoDB does not seem to be listening on 27017.');
    log('warn', 'Start MongoDB first, or point MONGODB_URI at an Atlas cluster in server/.env.');
  }

  if (await portInUse(5000)) {
    log('warn', 'Port 5000 is already in use — assuming the API is already running.');
  }

  log('dim', 'starting API (5000) and client (5173) — Ctrl+C stops both');

  const api = run('api', ['--prefix', 'server', 'run', 'dev']);
  // small head start so the first client requests have somewhere to land
  await new Promise((r) => setTimeout(r, 1500));
  const web = run('web', ['--prefix', 'client', 'run', 'dev']);

  const stop = () => {
    for (const child of [api, web]) {
      if (!child.killed) child.kill();
    }
    process.exit(0);
  };

  process.on('SIGINT', stop);
  process.on('SIGTERM', stop);
}

main();
