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
        'http://localhost:8080',
        'http://localhost:3000',
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
