import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://nolanmiller.me',
  output: 'static',
  build: {
    format: 'directory'
  },
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
      wrap: true
    }
  }
});
