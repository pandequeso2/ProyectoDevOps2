import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // Redirige las llamadas de despachos a su microservicio en K8s
      '/api/v1/despachos': {
        target: 'http://localhost:30081',
        changeOrigin: true,
      },
      // Redirige las llamadas de ventas a su microservicio en K8s
      '/api/v1/ventas': {
        target: 'http://localhost:30082',
        changeOrigin: true,
      }
    }
  }
})