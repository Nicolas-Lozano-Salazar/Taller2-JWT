/**
 * Prueba de humo de la API. Requiere que el servidor este corriendo.
 *
 *   npm start
 *   npm run smoke
 *
 * Ejercita el flujo CRUD completo, las validaciones y los codigos HTTP.
 */
const BASE_URL = process.env.API_URL ?? 'http://localhost:3000/api';

let aprobadas = 0;
let fallidas = 0;

const verificar = (condicion, descripcion, extra = '') => {
  if (condicion) {
    aprobadas += 1;
    console.log(`  OK   ${descripcion}`);
  } else {
    fallidas += 1;
    console.error(`  FAIL ${descripcion}${extra ? ` -> ${extra}` : ''}`);
  }
};

const peticion = async (metodo, ruta, cuerpo, token) => {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;

  const respuesta = await fetch(`${BASE_URL}${ruta}`, {
    method: metodo,
    headers,
    body: cuerpo ? JSON.stringify(cuerpo) : undefined,
  });

  let datos = null;
  const texto = await respuesta.text();
  if (texto) {
    try {
      datos = JSON.parse(texto);
    } catch {
      datos = texto;
    }
  }

  return { status: respuesta.status, datos };
};

const ejecutar = async () => {
  console.log(`\nPruebas de la API en ${BASE_URL}\n`);

  const salud = await peticion('GET', '/health');
  verificar(salud.status === 200 && salud.datos?.status === 'ok', 'GET /api/health responde 200');

  const loginInvalido = await peticion('POST', '/auth/login', {
    email: 'admin@inventario.com',
    password: 'incorrecta',
  });
  verificar(loginInvalido.status === 401, 'POST /api/auth/login con credenciales invalidas responde 401');

  const login = await peticion('POST', '/auth/login', {
    email: 'admin@inventario.com',
    password: 'Admin123!',
  });
  verificar(login.status === 200 && typeof login.datos?.data?.accessToken === 'string', 'POST /api/auth/login con credenciales validas responde 200');

  const token = login.datos?.data?.accessToken;
  const sinToken = await peticion('GET', '/productos');
  verificar(sinToken.status === 401, 'GET /api/productos sin token responde 401');

  const sesion = await peticion('GET', '/auth/me', null, token);
  verificar(sesion.status === 200 && sesion.datos?.data?.autenticado === true, 'GET /api/auth/me valida la sesion');

  const listado = await peticion('GET', '/productos', null, token);
  verificar(listado.status === 200 && Array.isArray(listado.datos?.data), 'GET /api/productos responde 200 con arreglo');
  verificar(
    (listado.datos?.data?.length ?? 0) >= 10,
    'Existen al menos 10 productos de prueba',
    `total=${listado.datos?.data?.length}`,
  );

  const primero = listado.datos.data[0];
  const detalle = await peticion('GET', `/productos/${primero.id}`, null, token);
  verificar(detalle.status === 200 && detalle.datos?.data?.id === primero.id, 'GET /api/productos/{id} devuelve el detalle');

  const inexistente = await peticion('GET', '/productos/999999', null, token);
  verificar(inexistente.status === 404, 'GET /api/productos/{id} inexistente responde 404');

  const nuevo = {
    nombre: 'Producto de prueba automatizada',
    codigo: `TEST-${Date.now()}`,
    descripcion: 'Registro creado por scripts/smoke-test.mjs',
    precio: 12345.5,
    cantidad: 7,
    categoria: 'Pruebas',
  };

  const creado = await peticion('POST', '/productos', nuevo, token);
  verificar(creado.status === 201 && creado.datos?.data?.codigo === nuevo.codigo, 'POST /api/productos responde 201');

  const duplicado = await peticion('POST', '/productos', nuevo, token);
  verificar(duplicado.status === 422, 'POST con codigo duplicado responde 422');

  const invalido = await peticion('POST', '/productos', { nombre: '', precio: -1, cantidad: 1.5, categoria: '' }, token);
  verificar(invalido.status === 422 && Array.isArray(invalido.datos?.error?.details), 'POST invalido responde 422 con detalles');

  const id = creado.datos?.data?.id;
  const actualizado = await peticion('PUT', `/productos/${id}`, {
    ...nuevo,
    nombre: 'Producto actualizado',
    precio: 15000,
    cantidad: 12,
  }, token);
  verificar(
    actualizado.status === 200 && actualizado.datos?.data?.nombre === 'Producto actualizado' && actualizado.datos?.data?.cantidad === 12,
    'PUT /api/productos/{id} actualiza el registro',
  );

  const eliminado = await peticion('DELETE', `/productos/${id}`, null, token);
  verificar(eliminado.status === 200, 'DELETE /api/productos/{id} responde 200');

  const borrado = await peticion('GET', `/productos/${id}`, null, token);
  verificar(borrado.status === 404, 'El producto eliminado ya no existe');

  const estadisticas = await peticion('GET', '/estadisticas', null, token);
  verificar(
    estadisticas.status === 200 &&
      typeof estadisticas.datos?.data?.totalProductos === 'number' &&
      typeof estadisticas.datos?.data?.valorInventario === 'number',
    'GET /api/estadisticas devuelve los indicadores del dashboard',
  );

  console.log(`\nResultado: ${aprobadas} pruebas aprobadas, ${fallidas} fallidas.\n`);
  process.exitCode = fallidas === 0 ? 0 : 1;
};

ejecutar().catch((error) => {
  console.error('\nNo se pudo conectar con la API. Verifique que el servidor este corriendo.\n', error.message);
  process.exitCode = 1;
});
