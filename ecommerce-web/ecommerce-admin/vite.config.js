import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5174,
    proxy: {
      '/api/v1/products': { target: 'http://localhost:8081', changeOrigin: true },
      '/api/v1/categories': { target: 'http://localhost:8081', changeOrigin: true },
      '/uploads': { target: 'http://localhost:8081', changeOrigin: true },
      '/api/v1/orders': { target: 'http://localhost:8083', changeOrigin: true },
      '/api/v1/users': { target: 'http://localhost:8084', changeOrigin: true },
      '/api/v1/payments': { target: 'http://localhost:8082', changeOrigin: true }
    }
  },
  resolve: { alias: { '@': '/src' } }
})
