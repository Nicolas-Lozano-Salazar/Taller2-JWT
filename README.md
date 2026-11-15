# Sistema de Gestion de Inventario — API REST + Flutter

**Segundo Parcial Practico — Electiva Profesional I**
*Desarrollo de Aplicaciones Moviles · Ingenieria de Sistemas*

Solucion completa para la administracion de productos de un establecimiento comercial. Incluye una **API REST con persistencia real en SQLite**, autenticacion mediante **JWT** y una **aplicacion movil Flutter** que consume la API mediante **Dio**, con navegacion declarativa usando **go_router**, almacenamiento seguro del token y configuracion de la URL base con **flutter_dotenv**.

> **Taller de JWT:** el login, la proteccion de endpoints, el almacenamiento seguro del token, el control de acceso a pantallas y el cierre de sesion estan implementados de extremo a extremo.

---

## 1. Tecnologias utilizadas

| Capa | Tecnologia |
|------|------------|
| Backend | Node.js 24 + Express 5 |
| Base de datos | SQLite (modulo nativo `node:sqlite`, persistencia en archivo) |
| Autenticacion | JWT (`jsonwebtoken`) + hash de contrasenas con `bcryptjs` |
| Cliente HTTP (Flutter) | `dio` (interceptor que agrega `Authorization: Bearer`) |
| Navegacion (Flutter) | `go_router` (redireccion a login si no hay sesion) |
| Almacenamiento seguro | `flutter_secure_storage` para el token |
| Datos no sensibles | `shared_preferences` para nombre y correo del usuario |
| Variables de entorno | `flutter_dotenv` |
| Formato de valores | `intl` |
| Pruebas | `node:test`-style smoke test con `fetch`, `flutter test` y `flutter analyze` |

> No se usan datos estaticos ni listas locales: **todas las operaciones CRUD viajan a la API y se almacenan en la base de datos**.

---



## 2. Ejecucion del backend

```powershell
cd backend
npm install
Copy-Item .env.example .env    
npm start
```

La API queda disponible en `http://localhost:3000` y crea automaticamente la base de datos en `backend/data/inventario.db` con **12 productos de prueba** (el enunciado exige minimo 10).

Para reiniciar la base de datos con los productos de prueba:

```powershell
npm run seed
```

Para desarrollo con recarga automatica:

```powershell
npm run dev
```

### Variables de entorno del backend

| Variable | Valor por defecto | Descripcion |
|----------|-------------------|-------------|
| `PORT` | `3000` | Puerto del servidor |
| `DB_PATH` | `data/inventario.db` | Archivo SQLite (relativo a `backend/`) |
| `CORS_ORIGIN` | `*` | Origenes permitidos, separados por coma |
| `SEED` | `true` | Carga los productos de prueba si la tabla esta vacia |
| `NODE_ENV` | `development` | Entorno de ejecucion |
| `JWT_SECRET` | `clave_super_secreta_cambiar_en_produccion` | Clave para firmar los tokens (cambiar en produccion) |
| `JWT_EXPIRES_IN` | `1h` | Vigencia del access token |

Al iniciar por primera vez, el backend crea el usuario de prueba:

| Usuario | Contrasena |
|---------|------------|
| `admin@inventario.com` | `Admin123!` |

> La contrasena se guarda como hash bcrypt, nunca en texto plano.

---

## 3. Endpoints de la API

Base URL: `http://localhost:3000/api`

| Metodo | Endpoint | Funcionalidad | Auth | Codigos |
|--------|----------|---------------|------|---------|
| `POST` | `/auth/login` | Validar credenciales y generar JWT | Publico | 200, 400, 401 |
| `GET` | `/auth/me` | Validar el token y devolver el usuario | Bearer | 200, 401 |
| `GET` | `/productos` | Listar todos los productos | Bearer | 200, 401 |
| `GET` | `/productos/{id}` | Consultar el detalle | Bearer | 200, 400, 401, 404 |
| `POST` | `/productos` | Registrar un producto | Bearer | 201, 401, 422 |
| `PUT` | `/productos/{id}` | Actualizar un producto | Bearer | 200, 400, 401, 404, 422 |
| `DELETE` | `/productos/{id}` | Eliminar un producto | Bearer | 200, 400, 401, 404 |
| `GET` | `/estadisticas` | Indicadores del dashboard | Bearer | 200, 401 |
| `GET` | `/health` | Estado del servicio | Publico | 200 |

Las rutas protegidas exigen el encabezado:

```http
Authorization: Bearer <access_token>
```

Si el token no se envia, es invalido o esta expirado, la API responde `401 Unauthorized`.

Endpoints adicionales de apoyo:

- `GET /api/productos?buscar=arroz` — filtra por nombre, codigo o categoria.
- `GET /api/productos?categoria=Alimentos` — filtra por categoria.

### 3.0. Ejemplo — iniciar sesion

```http
POST /api/auth/login
Content-Type: application/json
```

```json
{
  "email": "admin@inventario.com",
  "password": "Admin123!"
}
```

Respuesta `200 OK`:

```json
{
  "message": "Inicio de sesion exitoso.",
  "data": {
    "accessToken": "<jwt>",
    "tokenType": "Bearer",
    "expiresIn": "1h",
    "usuario": {
      "id": 1,
      "nombre": "Administrador",
      "email": "admin@inventario.com"
    }
  }
}
```

Credenciales incorrectas responden `401`:

```json
{
  "error": {
    "message": "Credenciales invalidas."
  }
}
```

### 3.1. Ejemplo — listar productos

```http
GET /api/productos
Authorization: Bearer <access_token>
```

```json
{
  "data": [
    {
      "id": 1,
      "nombre": "Aceite Girasol 1 L",
      "codigo": "ALI-002",
      "descripcion": "Aceite vegetal de girasol, botella de 1 litro.",
      "precio": 12500,
      "cantidad": 25,
      "categoria": "Alimentos"
    }
  ],
  "meta": {
    "total": 12,
    "filtros": { "buscar": "", "categoria": "" }
  }
}
```

### 3.2. Ejemplo — registrar producto

```http
POST /api/productos
Content-Type: application/json
Authorization: Bearer <access_token>
```

```json
{
  "nombre": "Televisor LED 32 pulgadas",
  "codigo": "TEC-002",
  "descripcion": "Televisor HD con dos puertos HDMI.",
  "precio": 899900,
  "cantidad": 6,
  "categoria": "Tecnologia"
}
```

Respuesta `201 Created`:

```json
{
  "message": "Producto registrado correctamente.",
  "data": {
    "id": 13,
    "nombre": "Televisor LED 32 pulgadas",
    "codigo": "TEC-002",
    "descripcion": "Televisor HD con dos puertos HDMI.",
    "precio": 899900,
    "cantidad": 6,
    "categoria": "Tecnologia"
  }
}
```

### 3.3. Ejemplo — error de validacion

```json
{
  "error": {
    "message": "Los datos del producto no son validos.",
    "details": [
      { "field": "nombre", "message": "El nombre es obligatorio." },
      { "field": "precio", "message": "El precio debe ser mayor o igual a 0." }
    ]
  }
}
```

### 3.4. Reglas de validacion

- `nombre`: obligatorio, entre 2 y 120 caracteres.
- `codigo`: obligatorio, unico, entre 2 y 40 caracteres (`A-Z`, `0-9`, `.`, `_`, `-`). Se normaliza a mayusculas.
- `descripcion`: opcional, maximo 500 caracteres.
- `precio`: obligatorio, numerico, mayor o igual a 0, con dos decimales.
- `cantidad`: obligatoria, entero mayor o igual a 0.
- `categoria`: obligatoria, entre 2 y 60 caracteres.
- Codigo duplicado: `422` con detalle del campo `codigo`.
- ID inexistente: `404`.
- JSON mal formado: `400`.

---

## 4. Ejecucion de la aplicacion Flutter

```powershell
cd frontend
flutter pub get
flutter run
```


```env
API_BASE_URL=http://10.0.2.2:3000/api
```

Ajuste la URL segun la plataforma:

| Plataforma | URL recomendada |
|------------|-----------------|
| Emulador Android | `http://10.0.2.2:3000/api` |
| iOS Simulator / escritorio / Chrome | `http://localhost:3000/api` |
| Dispositivo fisico | `http://IP_LOCAL_DE_SU_PC:3000/api` (ej. `http://192.168.0.10:3000/api`) |


### 4.1. Permisos ya configurados

- **Android:** `INTERNET`, `android:usesCleartextTraffic="true"` y `android:allowBackup="false"` en `android/app/src/main/AndroidManifest.xml`. El `minSdk` de Flutter es compatible con el minimo 23 que exige `flutter_secure_storage`.
- **iOS:** `NSAppTransportSecurity` con `NSAllowsArbitraryLoads` en `ios/Runner/Info.plist` para desarrollo local, y `Runner.entitlements` con Keychain Sharing para el almacenamiento seguro.
- **Web:** CORS habilitado en Express.
- En produccion use **HTTPS** y retire las excepciones de tráfico no seguro.

### 4.2. Funcionalidades de la app

- **Login** con validacion de campos, estado de carga y mensaje de error para credenciales invalidas.
- **Token JWT** almacenado con `flutter_secure_storage`; el nombre y correo del usuario se guardan con `shared_preferences`.
- **Interceptor Dio** que agrega `Authorization: Bearer <token>` a todas las peticiones protegidas.
- **Control de acceso** con `go_router`: sin sesion solo se puede acceder a `/login`; las rutas del dashboard, productos y sesion quedan restringidas.
- **Persistencia de sesion**: al reabrir la app se valida el token contra `GET /auth/me`.
- **Manejo de 401**: si el token expira o es invalido, se limpia la sesion y se redirige al login.
- **Pantalla de sesion** con nombre, correo, estado de autenticacion, indicador de token almacenado (sin mostrarlo) y boton de cierre de sesion.
- **Dashboard** con nombre e identidad visual, menu inferior, tarjetas de:
  - total de productos registrados,
  - total de unidades disponibles,
  - valor economico total (`precio x cantidad`),
  - aviso de stock bajo y numero de categorias.
- **Listado** con nombre, precio, cantidad, codigo y categoria; busqueda por nombre/codigo/categoria y actualizacion por gesto (pull to refresh).
- **Consulta de detalle** con todos los campos y valor total del producto.
- **Registro** mediante formulario con validaciones y peticion `POST`.
- **Edicion** con datos precargados desde la API y peticion `PUT`.
- **Eliminacion** con dialogo de confirmacion y peticion `DELETE`.
- **Estados de carga, error y lista vacia** en todas las pantallas.
- **Mensajes claros** de exito y error mediante `SnackBar`, incluyendo los detalles de validacion devueltos por la API.
- **Navegacion** con `go_router` (menu inferior y rutas anidadas para detalle/edicion).
- **Separacion de responsabilidades**: la vista nunca hace peticiones HTTP; usa `ProductoRepository`, que a su vez usa el cliente Dio.

### 4.3. Flujo de una operacion

```
LoginScreen
   ↓ llama
AuthController → AuthRepository
   ↓ usa
ApiClient (Dio + interceptor JWT) → POST /api/auth/login
   ↓ guarda token
flutter_secure_storage + shared_preferences
   ↓ redirige
Dashboard / Productos / Sesion (rutas protegidas por go_router)
   ↓
ProductoRepository → ApiClient (Authorization: Bearer <token>)
   ↓ HTTP/JSON
API REST (Express) → authMiddleware → controlador
   ↓ SQL
SQLite (backend/data/inventario.db)
```

---

## 5. Pruebas y calidad

### Backend

Con el servidor en ejecucion:

```powershell
cd backend
npm run smoke
```

Resultado esperado: **17 pruebas aprobadas, 0 fallidas** (login valido/invalido, 401 sin token y con token invalido, validacion de sesion, CRUD completo, validaciones, 404, duplicados y estadisticas).

### Flutter

```powershell
cd frontend
flutter analyze     # sin advertencias
flutter test        # 10 pruebas unitarias
```

Tambien puede verificarse la compilacion para web:

```powershell
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## 6. Base de datos

Archivo: `backend/data/inventario.db` (se crea automaticamente y se conserva al reiniciar el servidor).

```sql
CREATE TABLE productos (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre         TEXT    NOT NULL,
  codigo         TEXT    NOT NULL COLLATE NOCASE UNIQUE,
  descripcion    TEXT    NOT NULL DEFAULT '',
  precio         REAL    NOT NULL CHECK (precio >= 0),
  cantidad       INTEGER NOT NULL CHECK (cantidad >= 0),
  categoria      TEXT    NOT NULL,
  creado_en      TEXT    NOT NULL DEFAULT (datetime('now')),
  actualizado_en TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE usuarios (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre        TEXT    NOT NULL,
  email         TEXT    NOT NULL COLLATE NOCASE UNIQUE,
  password_hash TEXT    NOT NULL,
  creado_en     TEXT    NOT NULL DEFAULT (datetime('now'))
);
```

- `codigo` es unico sin distinguir mayusculas/minusculas.
- Los `CHECK` refuerzan la validacion a nivel de base de datos.
- La persistencia se demuestra creando un producto, reiniciando el backend y consultando de nuevo el listado.

Para inspeccionar la base de datos puede abrir el archivo con **DB Browser for SQLite** o ejecutar:

```powershell
cd backend
node -e "const {DatabaseSync}=require('node:sqlite'); const db=new DatabaseSync('data/inventario.db'); console.table(db.prepare('SELECT * FROM productos').all());"
```

---

## 7. Implementacion de autenticacion JWT

### Backend

1. `POST /api/auth/login` recibe `email` y `password`.
2. El usuario se busca en la tabla `usuarios` y la contrasena se compara con `bcrypt.compareSync`.
3. Si las credenciales son correctas se firma un JWT con `jsonwebtoken` usando `JWT_SECRET` y `JWT_EXPIRES_IN`.
4. `authMiddleware` lee `Authorization: Bearer <token>`, ejecuta `jwt.verify` y adjunta `req.user`.
5. Todos los endpoints de productos y estadisticas usan el middleware. Sin token, con token invalido o expirado responden `401`.
6. `GET /api/auth/me` valida el token y devuelve los datos basicos del usuario.

### Flutter

1. `LoginScreen` consume `POST /auth/login` mediante `Dio`.
2. El `access_token` se guarda en `flutter_secure_storage`; nombre, correo e id se guardan en `shared_preferences`.
3. Un interceptor de Dio agrega el encabezado `Authorization` en cada peticion.
4. `go_router` usa el estado de `AuthController` para redirigir a `/login` cuando no hay sesion.
5. Al iniciar la app se llama a `GET /auth/me` para validar la sesion persistida.
6. `SesionScreen` muestra usuario, correo, estado, si existe token (sin revelarlo) y permite cerrar sesion.
7. Ante un `401`, el interceptor limpia el almacenamiento y el controlador redirige al login.

### Escenarios de prueba manual

| Escenario | Como probarlo | Resultado esperado |
|-----------|---------------|--------------------|
| Acceso sin autenticacion | Abrir la app sin token | Redireccion a `/login` |
| Credenciales incorrectas | Password distinta a `Admin123!` | Mensaje de error, no ingresa |
| Login correcto | `admin@inventario.com` / `Admin123!` | Acceso al dashboard |
| CRUD protegido | Crear, editar o eliminar producto | Peticion con Bearer y respuesta exitosa |
| Persistencia | Cerrar y reabrir la app | Sesion mantenida si el token sigue vigente |
| Backend sin token | `curl http://localhost:3000/api/productos` | `401 Unauthorized` |
| Cierre de sesion | Boton en la pestana Sesion | Se borran token y datos, vuelve al login |

Ejemplo de verificacion directa del backend:

```powershell
# Sin token: debe responder 401
curl.exe -i http://localhost:3000/api/productos

# Login: guarda el token en una variable
$login = Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/auth/login `
  -ContentType 'application/json' `
  -Body '{"email":"admin@inventario.com","password":"Admin123!"}'
$token = $login.data.accessToken

# Con token: debe responder 200
curl.exe -H "Authorization: Bearer $token" http://localhost:3000/api/productos
