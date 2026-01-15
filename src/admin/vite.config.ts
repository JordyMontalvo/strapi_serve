import { mergeConfig, type UserConfig } from 'vite';

export default (config: UserConfig) => {
  // Important: always return the modified config
  return mergeConfig(config, {
    server: {
      host: '0.0.0.0',
      allowedHosts: [
        'cmsbiblioteca.aiep.cl',
        'cmsbibliotecatest.aiep.cl',
        '68.211.112.39',
        'localhost'
      ],
    },
    resolve: {
      alias: {
        '@': '/src',
      },
    },
  });
};
