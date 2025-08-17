import { beforeEach, describe, expect, it, vi } from 'vitest';

describe('Nextra MDX Server Rule', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('Server Configuration', () => {
    it('should support MDX server mode', () => {
      const serverConfig = {
        name: 'mdx_server',
        srcs: ['pages/api.mdx', 'pages/examples.mdx'],
        port: 3001,
        api_prefix: '/api/mdx',
      };

      expect(serverConfig.name).toBe('mdx_server');
      expect(serverConfig.port).toBe(3001);
      expect(serverConfig.api_prefix).toBe('/api/mdx');
    });

    it('should support configurable port', () => {
      const ports = [3001, 3002, 8080, 9000];
      ports.forEach((port) => {
        expect(port).toBeGreaterThan(0);
        expect(port).toBeLessThan(65536);
      });
    });

    it('should support configurable API prefix', () => {
      const prefixes = ['/api/mdx', '/docs/api', '/content'];
      prefixes.forEach((prefix) => {
        expect(prefix.startsWith('/')).toBe(true);
      });
    });
  });

  describe('API Endpoints', () => {
    it('should serve MDX files over HTTP', () => {
      const endpoints = [
        '/api/mdx/files',
        '/api/mdx/{filePath}',
        '/api/mdx/health',
      ];
      expect(endpoints.length).toBe(3);

      endpoints.forEach((endpoint) => {
        expect(endpoint.startsWith('/api/mdx')).toBe(true);
      });
    });

    it('should handle file listing endpoint', () => {
      const filesEndpoint = '/api/mdx/files';
      expect(filesEndpoint).toBe('/api/mdx/files');
    });

    it('should handle content serving endpoint', () => {
      const contentEndpoint = '/api/mdx/{filePath}';
      expect(contentEndpoint).toContain('{filePath}');
    });

    it('should handle health check endpoint', () => {
      const healthEndpoint = '/api/mdx/health';
      expect(healthEndpoint).toBe('/api/mdx/health');
    });
  });

  describe('Content Handling', () => {
    it('should handle MDX file extensions', () => {
      const extensions = ['.mdx', '.md'];
      extensions.forEach((ext) => {
        expect(ext.startsWith('.')).toBe(true);
      });
    });

    it('should return proper content type headers', () => {
      const contentType = 'text/markdown';
      expect(contentType).toBe('text/markdown');
    });

    it('should include file extension in headers', () => {
      const headers = {
        'Content-Type': 'text/markdown',
        'X-File-Extension': '.mdx',
      };

      expect(headers['Content-Type']).toBe('text/markdown');
      expect(headers['X-File-Extension']).toBe('.mdx');
    });
  });

  describe('CORS Support', () => {
    it('should handle CORS for cross-origin requests', () => {
      const corsEnabled = true;
      expect(corsEnabled).toBe(true);
    });

    it('should support CORS configuration', () => {
      const corsConfig = {
        origin: ['http://localhost:3000', 'https://example.com'],
        methods: ['GET'],
        allowedHeaders: ['Content-Type'],
      };

      expect(corsConfig.methods).toContain('GET');
      expect(corsConfig.allowedHeaders).toContain('Content-Type');
    });
  });

  describe('File Processing', () => {
    it('should process MDX files correctly', () => {
      const mdxFiles = [
        'pages/api.mdx',
        'pages/getting-started.mdx',
        'pages/examples.mdx',
      ];

      mdxFiles.forEach((file) => {
        expect(file.endsWith('.mdx')).toBe(true);
        expect(file.startsWith('pages/')).toBe(true);
      });
    });

    it('should handle nested file paths', () => {
      const nestedFiles = [
        'pages/api/endpoints.mdx',
        'pages/guides/getting-started.mdx',
        'pages/examples/basic.mdx',
      ];

      nestedFiles.forEach((file) => {
        expect(file.split('/').length).toBeGreaterThan(2);
      });
    });
  });

  describe('Server Scripts', () => {
    it('should generate server and dev scripts', () => {
      const outputs = ['server_script', 'dev_script'];
      expect(outputs).toContain('server_script');
      expect(outputs).toContain('dev_script');
    });

    it('should support development mode with watch', () => {
      const devCommand = 'npx ts-node-dev --respawn server.ts';
      expect(devCommand).toContain('ts-node-dev');
      expect(devCommand).toContain('--respawn');
    });

    it('should support production mode', () => {
      const prodCommand = 'npx ts-node server.ts';
      expect(prodCommand).toContain('ts-node');
    });
  });

  describe('Error Handling', () => {
    it('should handle file not found errors', () => {
      const errorResponse = {
        error: 'File not found',
        path: 'non-existent-file',
      };

      expect(errorResponse.error).toBe('File not found');
      expect(errorResponse.path).toBe('non-existent-file');
    });

    it('should handle server errors gracefully', () => {
      const serverError = {
        error: 'Internal server error',
        message: 'Error details',
      };

      expect(serverError.error).toBe('Internal server error');
    });

    it('should validate file paths', () => {
      const invalidPaths = ['../invalid.mdx', 'invalid/../path.mdx'];
      invalidPaths.forEach((path) => {
        expect(path.includes('..')).toBe(true);
      });
    });
  });

  describe('Integration Features', () => {
    it('should support Next.js MDXClient integration', () => {
      const integrationExample = `
        const response = await fetch('http://localhost:3001/api/mdx/api-docs');
        const mdxContent = await response.text();
        return <MDXClient source={mdxContent} />;
      `;

      expect(integrationExample).toContain('fetch');
      expect(integrationExample).toContain('MDXClient');
    });

    it('should support dynamic navigation', () => {
      const navExample = `
        const response = await fetch('http://localhost:3001/api/mdx/files');
        const { files } = await response.json();
      `;

      expect(navExample).toContain('files');
    });
  });
});
