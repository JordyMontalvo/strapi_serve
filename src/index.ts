import type { Core } from '@strapi/strapi';

export default {
  /**
   * An asynchronous register function that runs before
   * your application is initialized.
   *
   * This gives you an opportunity to extend code.
   */
  register(/* { strapi }: { strapi: Core.Strapi } */) {},

  /**
   * An asynchronous bootstrap function that runs before
   * your application gets started.
   *
   * This gives you an opportunity to set up your data model,
   * run jobs, or perform some special logic.
   */
  async bootstrap({ strapi }: { strapi: Core.Strapi }) {
    // Configurar permisos públicos para hero-banners automáticamente
    // Esperar a que Strapi esté completamente iniciado
    setTimeout(async () => {
      try {
        const publicRole = await strapi
          .query('plugin::users-permissions.role')
          .findOne({ where: { type: 'public' } });

        if (publicRole) {
          // Verificar si hero-banner ya tiene permisos
          const existingPermissions = await strapi
            .query('plugin::users-permissions.permission')
            .findMany({
              where: {
                role: publicRole.id,
                action: {
                  $in: [
                    'api::hero-banner.hero-banner.find',
                    'api::hero-banner.hero-banner.findOne',
                  ],
                },
              },
            });

          // Si no tiene permisos, crearlos
          if (existingPermissions.length === 0) {
            await strapi
              .query('plugin::users-permissions.permission')
              .create({
                data: {
                  action: 'api::hero-banner.hero-banner.find',
                  role: publicRole.id,
                },
              });

            await strapi
              .query('plugin::users-permissions.permission')
              .create({
                data: {
                  action: 'api::hero-banner.hero-banner.findOne',
                  role: publicRole.id,
                },
              });

            strapi.log.info('✅ Permisos públicos configurados para hero-banner');
          } else {
            strapi.log.info('✅ Permisos públicos para hero-banner ya existen');
          }
        }
      } catch (error: any) {
        strapi.log.warn('⚠️ No se pudieron configurar permisos automáticamente. Configúralos manualmente desde el admin panel.');
        if (error?.message) {
          strapi.log.debug(`Error: ${error.message}`);
        }
      }
    }, 5000); // Esperar 5 segundos después del bootstrap
  },
};
