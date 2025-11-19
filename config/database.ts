import path from 'path';

export default ({ env }) => {
  const client = env('DATABASE_CLIENT', 'sqlite');

  const connections = {
    mysql: {
      connection: {
        host: env('DATABASE_HOST', 'localhost'),
        port: env.int('DATABASE_PORT', 3306),
        database: env('DATABASE_NAME', 'strapi'),
        user: env('DATABASE_USERNAME', 'strapi'),
        password: env('DATABASE_PASSWORD', 'strapi'),
        ssl: env.bool('DATABASE_SSL', false) && {
          key: env('DATABASE_SSL_KEY', undefined),
          cert: env('DATABASE_SSL_CERT', undefined),
          ca: env('DATABASE_SSL_CA', undefined),
          capath: env('DATABASE_SSL_CAPATH', undefined),
          cipher: env('DATABASE_SSL_CIPHER', undefined),
          rejectUnauthorized: env.bool('DATABASE_SSL_REJECT_UNAUTHORIZED', true),
        },
      },
      pool: { min: env.int('DATABASE_POOL_MIN', 2), max: env.int('DATABASE_POOL_MAX', 10) },
    },
    postgres: {
      connection: (() => {
        // Preferir variables individuales para evitar problemas con IPv6
        // Si DATABASE_HOST está definido, usar configuración individual
        if (env('DATABASE_HOST')) {
          return {
            host: env('DATABASE_HOST'),
            port: env.int('DATABASE_PORT', 5432),
            database: env('DATABASE_NAME', 'postgres'),
            user: env('DATABASE_USERNAME', 'postgres'),
            password: env('DATABASE_PASSWORD'),
            ssl: env.bool('DATABASE_SSL', false) && {
              rejectUnauthorized: env.bool('DATABASE_SSL_REJECT_UNAUTHORIZED', false),
            },
            schema: env('DATABASE_SCHEMA', 'public'),
          };
        }
        
        // Si solo hay DATABASE_URL, usarla pero parsearla para evitar problemas
        const dbUrl = env('DATABASE_URL');
        if (dbUrl) {
          // Intentar parsear la URL para extraer componentes
          try {
            const url = new URL(dbUrl.replace(/^postgresql:/, 'postgres:'));
            return {
              host: url.hostname,
              port: parseInt(url.port) || 5432,
              database: url.pathname.replace('/', '') || 'postgres',
              user: url.username || 'postgres',
              password: url.password || '',
              ssl: env.bool('DATABASE_SSL', true) && {
                rejectUnauthorized: env.bool('DATABASE_SSL_REJECT_UNAUTHORIZED', false),
              },
              schema: env('DATABASE_SCHEMA', 'public'),
            };
          } catch (e) {
            // Si falla el parseo, usar connectionString directamente
            return {
              connectionString: dbUrl,
              ssl: env.bool('DATABASE_SSL', true) && {
                rejectUnauthorized: env.bool('DATABASE_SSL_REJECT_UNAUTHORIZED', false),
              },
              schema: env('DATABASE_SCHEMA', 'public'),
            };
          }
        }
        
        // Fallback a valores por defecto
        return {
          host: env('DATABASE_HOST', 'localhost'),
          port: env.int('DATABASE_PORT', 5432),
          database: env('DATABASE_NAME', 'strapi'),
          user: env('DATABASE_USERNAME', 'strapi'),
          password: env('DATABASE_PASSWORD', 'strapi'),
          ssl: env.bool('DATABASE_SSL', false) && {
            rejectUnauthorized: env.bool('DATABASE_SSL_REJECT_UNAUTHORIZED', false),
          },
          schema: env('DATABASE_SCHEMA', 'public'),
        };
      })(),
      pool: { min: env.int('DATABASE_POOL_MIN', 2), max: env.int('DATABASE_POOL_MAX', 10) },
    },
    sqlite: {
      connection: {
        filename: path.join(__dirname, '..', '..', env('DATABASE_FILENAME', '.tmp/data.db')),
      },
      useNullAsDefault: true,
    },
  };

  return {
    connection: {
      client,
      ...connections[client],
      acquireConnectionTimeout: env.int('DATABASE_CONNECTION_TIMEOUT', 60000),
    },
  };
};
