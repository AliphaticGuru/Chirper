import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    server: {
        host: '0.0.0.0', 
        // origin: 'http://host.docker.internal:5173',
        strictPort: true,
        port: 5173,
        hmr: {
            host: process.env.VITE_DEV_SERVER_HOST || 'localhost',
            protocol: 'ws',
            port: 5173,
        },
        // watch: {
        //     usePolling: true,
        // }
    },
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
        tailwindcss()
    ],
    build: {
        manifest: true,
        outDir: 'public/build',
        rollupOptions: {
            input: ['resources/css/app.css', 'resources/js/app.js'],
        },
    },
});