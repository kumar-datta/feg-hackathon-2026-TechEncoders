import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const API_TARGET = process.env.VITE_API_TARGET || 'http://localhost:5000';

/** Print the "start the API" hint once instead of a stack trace per request. */
let warnedOffline = false;

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      // forwards /api to the Express server so the client can use relative URLs
      '/api': {
        target: API_TARGET,
        changeOrigin: true,
        configure: (proxy) => {
          proxy.on('error', (err, _req, res) => {
            if (err.code === 'ECONNREFUSED' || err.code === 'ECONNRESET') {
              if (!warnedOffline) {
                warnedOffline = true;
                console.log(
                  `\n\x1b[33m⚠  API not reachable at ${API_TARGET}\x1b[0m\n` +
                  `   The front end is running, but nothing is serving /api.\n` +
                  `   Start it in another terminal:  \x1b[36mnpm run server\x1b[0m\n` +
                  `   Or run both at once:           \x1b[36mnpm run dev\x1b[0m\n` +
                  `   (further proxy errors are suppressed)\n`
                );
              }
            } else {
              console.log(`[vite] proxy error: ${err.message}`);
            }

            // answer the browser so requests fail fast with a readable message
            if (res && !res.headersSent && typeof res.writeHead === 'function') {
              res.writeHead(503, { 'Content-Type': 'application/json' });
              res.end(JSON.stringify({ error: 'API unavailable. Start it with: npm run server' }));
            }
          });

          proxy.on('proxyRes', () => { warnedOffline = false; });
        }
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: false
  }
});
