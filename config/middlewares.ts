export default [
  'strapi::logger',
  'strapi::errors',
  'strapi::security',
  {
    name: 'strapi::cors',
    config: {
      enabled: true,
      origin: [
        'https://portal-bibliotecatest.aiep.cl',
        'https://portal-biblioteca.aiep.cl',
        // 'http://localhost:8080', // Solo para desarrollo local
        // 'http://localhost:3000', // Solo para desarrollo local
      ],
      credentials: false, // Deshabilitar credentials para endpoints públicos
    },
  },
  'strapi::poweredBy',
  'strapi::query',
  'strapi::body',
  'strapi::session',
  'strapi::favicon',
  'strapi::public',
];
