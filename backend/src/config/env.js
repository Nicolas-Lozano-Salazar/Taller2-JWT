import path from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const backendRoot = path.resolve(__dirname, '../..');

dotenv.config({ path: path.join(backendRoot, '.env') });

const parseBoolean = (value, fallback = true) => {
  if (value === undefined) return fallback;
  return ['1', 'true', 'yes', 'si', 'sí'].includes(String(value).toLowerCase());
};

export const env = {
  port: Number(process.env.PORT ?? 3000),
  dbPath: path.resolve(backendRoot, process.env.DB_PATH ?? 'data/inventario.db'),
  corsOrigin: process.env.CORS_ORIGIN ?? '*',
  seed: parseBoolean(process.env.SEED, true),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  isProduction: (process.env.NODE_ENV ?? 'development') === 'production',
};
