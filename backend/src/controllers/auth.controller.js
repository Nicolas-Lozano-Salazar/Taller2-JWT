import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

import { env } from '../config/env.js';
import { usuarioModel } from '../models/usuario.model.js';
import { ApiError } from '../utils/ApiError.js';

const sanitizarUsuario = (usuario) => ({
  id: usuario.id,
  nombre: usuario.nombre,
  email: usuario.email,
});

export const authController = {
  login(req, res) {
    const email = typeof req.body?.email === 'string' ? req.body.email.trim() : '';
    const password = typeof req.body?.password === 'string' ? req.body.password : '';

    if (!email || !password) {
      throw ApiError.badRequest('Email y password son obligatorios.');
    }

    const usuario = usuarioModel.obtenerPorEmail(email);
    if (!usuario) {
      throw ApiError.unauthorized('Credenciales invalidas.');
    }

    const passwordValida = bcrypt.compareSync(password, usuario.password_hash);
    if (!passwordValida) {
      throw ApiError.unauthorized('Credenciales invalidas.');
    }

    const token = jwt.sign(
      { sub: usuario.id, email: usuario.email, nombre: usuario.nombre },
      env.jwtSecret,
      { expiresIn: env.jwtExpiresIn },
    );

    res.json({
      message: 'Inicio de sesion exitoso.',
      data: {
        accessToken: token,
        tokenType: 'Bearer',
        expiresIn: env.jwtExpiresIn,
        usuario: sanitizarUsuario(usuario),
      },
    });
  },

  me(req, res) {
    const usuario = usuarioModel.obtenerPorId(req.user.id);
    if (!usuario) {
      throw ApiError.unauthorized('La sesion ya no es valida.');
    }

    res.json({
      data: {
        usuario: {
          id: usuario.id,
          nombre: usuario.nombre,
          email: usuario.email,
        },
        autenticado: true,
        tokenPresente: true,
      },
    });
  },
};