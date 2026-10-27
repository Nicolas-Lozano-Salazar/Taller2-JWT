import { Router } from 'express';
import { productoController } from '../controllers/producto.controller.js';

export const productoRouter = Router();

productoRouter.get('/', productoController.listar);
productoRouter.get('/:id', productoController.obtener);
productoRouter.post('/', productoController.crear);
productoRouter.put('/:id', productoController.actualizar);
productoRouter.delete('/:id', productoController.eliminar);
