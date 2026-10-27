import { Router } from 'express';
import { productoRouter } from './producto.routes.js';
import { productoController } from '../controllers/producto.controller.js';

export const apiRouter = Router();

apiRouter.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    servicio: 'API de Inventario',
    version: '1.0.0',
    fecha: new Date().toISOString(),
  });
});

apiRouter.get('/estadisticas', productoController.estadisticas);
apiRouter.use('/productos', productoRouter);
