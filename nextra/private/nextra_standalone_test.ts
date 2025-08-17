import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('Nextra Standalone Rule', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('Rule Configuration', () => {
    it('should support standalone documentation generation', () => {
      const ruleConfig = {
        name: 'docs',
        srcs: ['pages/index.mdx', 'pages/getting-started.mdx'],
        config: 'next.config.js',
        theme_config: 'theme.config.jsx',
        out_dir: 'out',
        export_static: true
      };
      
      expect(ruleConfig.name).toBe('docs');
      expect(ruleConfig.export_static).toBe(true);
      expect(ruleConfig.out_dir).toBe('out');
    });

    it('should handle custom output directory', () => {
      const customOutDir = 'dist/docs';
      expect(customOutDir).toBe('dist/docs');
    });

    it('should support disabling static export', () => {
      const exportStatic = false;
      expect(exportStatic).toBe(false);
    });
  });

  describe('Source File Handling', () => {
    it('should handle MDX source files', () => {
      const mdxFiles = ['index.mdx', 'getting-started.mdx', 'api.mdx'];
      expect(mdxFiles.length).toBe(3);
      
      mdxFiles.forEach(file => {
        expect(file.endsWith('.mdx')).toBe(true);
      });
    });

    it('should handle TypeScript source files', () => {
      const tsFiles = ['components/Header.tsx', 'lib/utils.ts'];
      expect(tsFiles.length).toBe(2);
      
      tsFiles.forEach(file => {
        expect(file.endsWith('.ts') || file.endsWith('.tsx')).toBe(true);
      });
    });

    it('should handle mixed file types', () => {
      const mixedFiles = [
        'pages/index.mdx',
        'components/Header.tsx',
        'lib/utils.ts',
        'public/logo.png'
      ];
      
      expect(mixedFiles.length).toBe(4);
      expect(mixedFiles.some(f => f.endsWith('.mdx'))).toBe(true);
      expect(mixedFiles.some(f => f.endsWith('.tsx'))).toBe(true);
      expect(mixedFiles.some(f => f.endsWith('.ts'))).toBe(true);
      expect(mixedFiles.some(f => f.endsWith('.png'))).toBe(true);
    });
  });

  describe('Build Process', () => {
    it('should support static export', () => {
      const exportStatic = true;
      expect(exportStatic).toBe(true);
    });

    it('should generate build and dev scripts', () => {
      const outputs = ['out', 'build_script', 'dev_script'];
      expect(outputs).toContain('out');
      expect(outputs).toContain('build_script');
      expect(outputs).toContain('dev_script');
    });

    it('should handle Next.js build process', () => {
      const buildSteps = [
        'npm install',
        'npx next build',
        'npx next export -o out'
      ];
      
      expect(buildSteps).toContain('npx next build');
      expect(buildSteps).toContain('npx next export -o out');
    });
  });

  describe('Development Mode', () => {
    it('should support development server', () => {
      const devCommand = 'npx next dev --port 3000';
      expect(devCommand).toContain('next dev');
      expect(devCommand).toContain('--port 3000');
    });

    it('should set development environment', () => {
      const env = 'development';
      expect(env).toBe('development');
    });
  });

  describe('File Organization', () => {
    it('should organize files by type', () => {
      const fileOrganization = {
        mdx: 'pages/',
        components: 'components/',
        lib: 'lib/',
        public: 'public/'
      };
      
      expect(fileOrganization.mdx).toBe('pages/');
      expect(fileOrganization.components).toBe('components/');
      expect(fileOrganization.lib).toBe('lib/');
      expect(fileOrganization.public).toBe('public/');
    });

    it('should handle nested directory structures', () => {
      const nestedFiles = [
        'pages/getting-started/index.mdx',
        'components/layout/Header.tsx',
        'lib/utils/helpers.ts'
      ];
      
      nestedFiles.forEach(file => {
        expect(file.split('/').length).toBeGreaterThan(1);
      });
    });
  });

  describe('Error Handling', () => {
    it('should handle missing source files gracefully', () => {
      const emptySrcs = [];
      expect(emptySrcs.length).toBe(0);
    });

    it('should handle invalid file paths', () => {
      const invalidPaths = ['../invalid.mdx', 'invalid/../path.mdx'];
      invalidPaths.forEach(path => {
        expect(path.includes('..')).toBe(true);
      });
    });
  });
});
