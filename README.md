# Sistema de Gestion de Inventario — API REST + Flutter

**Segundo Parcial Practico — Electiva Profesional I**
*Desarrollo de Aplicaciones Moviles · Ingenieria de Sistemas*

Solucion completa para la administracion de productos de un establecimiento comercial. Incluye una **API REST con persistencia real en SQLite** y una **aplicacion movil Flutter** que consume la API mediante **Dio**, con navegacion declarativa usando **go_router** y configuracion de la URL base con **flutter_dotenv**.

---

## 1. Tecnologias utilizadas

| Capa | Tecnologia |
|------|------------|
| Backend | Node.js 24 + Express 5 |
| Base de datos | SQLite (modulo nativo `node:sqlite`, persistencia en archivo) |
| Cliente HTTP (Flutter) | `dio` |
| Navegacion (Flutter) | `go_router` |
| Variables de entorno | `flutter_dotenv` |
| Formato de valores | `intl` |
| Pruebas | `node:test`-style smoke test con `fetch`, `flutter test` y `flutter analyze` |

> No se usan datos estaticos ni listas locales: **todas las operaciones CRUD viajan a la API y se almacenan en la base de datos**.

---

## 2. Estructura del repositorio

```
inventario/
├── backend/                     # API REST (Node.js + Express + SQLite)
│   ├── scripts/
│   │   └── smoke-test.mjs       # Prueba automatizada de todos los endpoints
│   ├── src/
│   │   ├── config/env.js        # Variables de entorno y rutas
│   │   ├── controllers/         # Logica HTTP (request/response)
│   │   ├── db/                  # Conexion SQLite, esquema y datos de prueba
│   │   ├── middlewares/         # Manejo centralizado de errores
│   │   ├── models/              # Acceso a datos (consultas SQL)
│   │   ├── routes/              # Definicion de endpoints
│   │   ├── utils/               # Error controlado de la API
│   │   ├── validators/          # Validacion y normalizacion de campos
│   │   ├── app.js               # Configuracion de Express
│   │   └── server.js            # Arranque del servidor
│   ├── .env.example
│   └── package.json
│
├── frontend/                    # Aplicacion Flutter
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/          # URL base desde .env
│   │   │   ├── network/         # Cliente Dio y excepciones propias
│   │   │   └── utils/           # Formatos de moneda y numeros
│   │   ├── data/
│   │   │   ├── models/          # Producto y Estadisticas
│   │   │   └── repositories/    # Consumo de la API (unico uso de Dio)
│   │   ├── presentation/
│   │   │   ├── screens/         # Dashboard, listado, detalle y formulario
│   │   │   ├── theme/           # Tema Material 3
│   │   │   └── widgets/         # Componentes reutilizables
│   │   ├── routes/app_router.dart
│   │   └── main.dart
│   ├── test/producto_test.dart
│   ├── .env                     # URL base local (no contiene secretos)
│   └── pubspec.yaml
│
├── docs/
│   ├── GUIA-VIDEO-Y-PDF.md      # Guion del video y checklist del PDF
│   └── evidencias/              # Espacio para capturas del informe
├── .gitignore
└── README.md
```

---



## 3. Ejecucion del backend

```powershell
cd backend
npm install
Copy-Item .env.example .env    # en Linux/macOS: cp .env.example .env
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

---

## 4. Endpoints de la API

Base URL: `http://localhost:3000/api`

| Metodo | Endpoint | Funcionalidad | Codigos |
|--------|----------|---------------|---------|
| `GET` | `/productos` | Listar todos los productos | 200 |
| `GET` | `/productos/{id}` | Consultar el detalle | 200, 400, 404 |
| `POST` | `/productos` | Registrar un producto | 201, 422 |
| `PUT` | `/productos/{id}` | Actualizar un producto | 200, 400, 404, 422 |
| `DELETE` | `/productos/{id}` | Eliminar un producto | 200, 400, 404 |
| `GET` | `/estadisticas` | Indicadores del dashboard | 200 |
| `GET` | `/health` | Estado del servicio | 200 |

Endpoints adicionales de apoyo:

- `GET /api/productos?buscar=arroz` — filtra por nombre, codigo o categoria.
- `GET /api/productos?categoria=Alimentos` — filtra por categoria.

### 4.1. Ejemplo — listar productos

```http
GET /api/productos
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

### 4.2. Ejemplo — registrar producto

```http
POST /api/productos
Content-Type: application/json
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

### 4.3. Ejemplo — error de validacion

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

### 4.4. Reglas de validacion

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

## 5. Ejecucion de la aplicacion Flutter

```powershell
cd frontend
flutter pub get
flutter run
```

El archivo `frontend/.env` ya viene configurado para el **emulador Android**:

```env
API_BASE_URL=http://10.0.2.2:3000/api
```

Ajuste la URL segun la plataforma:

| Plataforma | URL recomendada |
|------------|-----------------|
| Emulador Android | `http://10.0.2.2:3000/api` |
| iOS Simulator / escritorio / Chrome | `http://localhost:3000/api` |
| Dispositivo fisico | `http://IP_LOCAL_DE_SU_PC:3000/api` (ej. `http://192.168.0.10:3000/api`) |


### 5.1. Permisos ya configurados

- **Android:** `INTERNET` y `android:usesCleartextTraffic="true"` en `android/app/src/main/AndroidManifest.xml` para permitir HTTP local durante el desarrollo.
- **iOS:** `NSAppTransportSecurity` con `NSAllowsArbitraryLoads` en `ios/Runner/Info.plist` para desarrollo local.
- **Web:** CORS habilitado en Express.
- En produccion use **HTTPS** y retire las excepciones de tráfico no seguro.

### 5.2. Funcionalidades de la app

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

### 5.3. Flujo de una operacion

```
Widget (pantalla)
   ↓ llama
ProductoRepository
   ↓ usa
ApiClient (Dio + baseUrl desde .env)
   ↓ HTTP/JSON
API REST (Express)
   ↓ SQL
SQLite (backend/data/inventario.db)
```

---

## 6 Pruebas y calidad

### Backend

Con el servidor en ejecucion:

```powershell
cd backend
npm run smoke
```

Resultado esperado: **12 pruebas aprobadas, 0 fallidas** (CRUD completo, validaciones, 404, duplicados y estadisticas).

### Flutter

```powershell
cd frontend
flutter analyze     # sin advertencias
flutter test        # 7 pruebas unitarias
```

Tambien puede verificarse la compilacion para web:

```powershell
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## 7. Base de datos

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
```

- `codigo` es unico sin distinguir mayusculas/minusculas.
- Los `CHECK` refuerzan la validacion a nivel de base de datos.
- La persistencia se demuestra creando un producto, reiniciando el backend y consultando de nuevo el listado.

Para inspeccionar la base de datos puede abrir el archivo con **DB Browser for SQLite** o ejecutar:

```powershell
cd backend
node -e "const {DatabaseSync}=require('node:sqlite'); const db=new DatabaseSync('data/inventario.db'); console.table(db.prepare('SELECT * FROM productos').all());"
```
