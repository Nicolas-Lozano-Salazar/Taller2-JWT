import express from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import { apiRouter } from './routes/index.js';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware.js';

export const app = express();

app.disable('x-powered-by');
app.use(
  cors({
    origin: env.corsOrigin === '*' ? true : env.corsOrigin.split(',').map((origen) => origen.trim()),
  }),
);
app.use(express.json({ limit: '256kb' }));
app.use(express.urlencoded({ extended: false }));

if (!env.isProduction) {
  app.use((req, res, next) => {
    const inicio = Date.now();
    res.on('finish', () => {
      console.log(`[api] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${Date.now() - inicio} ms)`);
    });
    next();
  });
}

app.get('/', (_req, res) => {
  res.json({
    mensaje: 'API REST de Inventario - Segundo Parcial Practico',
    documentacion: '/api/health',
    endpoints: {
      listar: 'GET /api/productos',
      detalle: 'GET /api/productos/{id}',
      crear: 'POST /api/productos',
      actualizar: 'PUT /api/productos/{id}',
      eliminar: 'DELETE /api/productos/{id}',
      estadisticas: 'GET /api/estadisticas',
    },
  });
});

app.use('/api', apiRouter);

app.use(notFoundHandler);
app.use(errorHandler);
