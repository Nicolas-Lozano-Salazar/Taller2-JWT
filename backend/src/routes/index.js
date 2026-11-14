import { Router } from 'express';
import { productoRouter } from './producto.routes.js';
import { productoController } from '../controllers/producto.controller.js';
import { authRouter } from './auth.routes.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

export const apiRouter = Router();

apiRouter.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    servicio: 'API de Inventario',
    version: '1.0.0',
    fecha: new Date().toISOString(),
  });
});

apiRouter.use('/auth', authRouter);
apiRouter.get('/estadisticas', authMiddleware, productoController.estadisticas);
apiRouter.use('/productos', authMiddleware, productoRouter);
