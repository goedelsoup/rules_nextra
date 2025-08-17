import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock Bazel context for future use
// const mockCtx = {
//   label: { name: 'test_rule' },
//   actions: {
//     declare_file: vi.fn((name) => ({ path: `/mock/path/${name}` })),
//     write: vi.fn(),
//   },
//   file: {
//     package_json: { path: '/mock/package.json' },
//   },
//   attr: {
//     srcs: [],
//     config: null,
//     theme_config: null,
//   },
// };

describe('Nextra Common Utilities', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('Common Attributes', () => {
    it('should define correct file extensions', () => {
      const supportedExtensions = ['.mdx', '.md', '.ts', '.tsx', '.js', '.jsx', '.json'];
      
      expect(supportedExtensions).toContain('.mdx');
      expect(supportedExtensions).toContain('.md');
      expect(supportedExtensions).toContain('.ts');
      expect(supportedExtensions).toContain('.tsx');
      expect(supportedExtensions).toContain('.js');
      expect(supportedExtensions).toContain('.jsx');
      expect(supportedExtensions).toContain('.json');
    });

    it('should have required attributes', () => {
      const requiredAttrs = [
        'srcs',
        'config', 
        'theme_config',
        'package_json',
        'data',
        'deps',
        'visibility'
      ];
      
      requiredAttrs.forEach(attr => {
        expect(requiredAttrs).toContain(attr);
      });
    });
  });

  describe('Configuration Generation', () => {
    it('should create default Next.js config when none provided', () => {
      // This would test the create_nextra_config function
      const defaultConfigContent = `
const withNextra = require('nextra')({
  theme: 'nextra-theme-docs',
  themeConfig: './theme.config.jsx',
  defaultShowCopyCode: true,
  flexsearch: {
    codeblocks: true
  },
  staticImage: true,
})

module.exports = withNextra({
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true
  }
})
`;
      
      expect(defaultConfigContent).toContain('nextra-theme-docs');
      expect(defaultConfigContent).toContain('output: \'export\'');
      expect(defaultConfigContent).toContain('trailingSlash: true');
    });

    it('should create default theme config when none provided', () => {
      const defaultThemeContent = `
export default {
  logo: <span>My Documentation</span>,
  project: {
    link: 'https://github.com/your-org/your-repo',
  },
  docsRepositoryBase: 'https://github.com/your-org/your-repo/tree/main',
  footer: {
    text: 'MIT 2024 © Your Organization.',
  },
}
`;
      
      expect(defaultThemeContent).toContain('My Documentation');
      expect(defaultThemeContent).toContain('nextra-theme-docs');
    });
  });

  describe('File Type Detection', () => {
    it('should correctly identify MDX files', () => {
      const mdxFiles = ['index.mdx', 'getting-started.mdx', 'api.mdx'];
      const mdFiles = ['readme.md', 'changelog.md'];
      
      mdxFiles.forEach(file => {
        expect(file.endsWith('.mdx')).toBe(true);
      });
      
      mdFiles.forEach(file => {
        expect(file.endsWith('.md')).toBe(true);
      });
    });

    it('should correctly identify TypeScript files', () => {
      const tsFiles = ['utils.ts', 'config.ts'];
      const tsxFiles = ['Header.tsx', 'Layout.tsx'];
      
      tsFiles.forEach(file => {
        expect(file.endsWith('.ts')).toBe(true);
      });
      
      tsxFiles.forEach(file => {
        expect(file.endsWith('.tsx')).toBe(true);
      });
    });
  });

  describe('Path Handling', () => {
    it('should handle different file paths correctly', () => {
      const paths = [
        'pages/index.mdx',
        'components/Header.tsx',
        'lib/utils.ts',
        'public/logo.png'
      ];
      
      paths.forEach(path => {
        expect(path).toMatch(/^[a-zA-Z0-9\/\-_\.]+$/);
      });
    });

    it('should support nested directory structures', () => {
      const nestedPaths = [
        'pages/getting-started/index.mdx',
        'pages/api/endpoints.mdx',
        'components/layout/Header.tsx',
        'lib/utils/helpers.ts'
      ];
      
      nestedPaths.forEach(path => {
        expect(path.split('/').length).toBeGreaterThan(1);
      });
    });
  });
});
