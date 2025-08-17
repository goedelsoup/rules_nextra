# Bazel Nextra Documentation Rules

A comprehensive set of Bazel rules for easily adding Nextra v4 static documentation sites to services/libraries in a monorepo. This ruleset supports both standalone documentation sites and MDX server modes for remote content consumption.

## Features

- **Two Operating Modes**:
  - **Standalone Server Mode**: Complete static documentation sites
  - **MDX Server Mode**: HTTP server serving raw MDX content for Next.js MDXClient
- **Nextra v4 Support**: Latest Nextra with docs theme/plugin
- **Bazel Integration**: Clean integration with aspect-build/rules_ts
- **Development Experience**: Hot-reload and watch mode support
- **Monorepo Ready**: Works seamlessly in monorepo environments

## Quick Start

### 1. Add to Your WORKSPACE

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_nextra",
    sha256 = "your-sha256-here",
    strip_prefix = "rules_nextra-1.0.0",
    url = "https://github.com/your-org/rules_nextra/releases/download/v1.0.0/rules_nextra-v1.0.0.tar.gz",
)

load("@rules_nextra//nextra:defs.bzl", "nextra_standalone", "nextra_mdx_server")
```

### 2. Create Documentation

#### Standalone Documentation Site

```python
# BUILD.bazel
load("@rules_nextra//nextra:defs.bzl", "nextra_standalone")

nextra_standalone(
    name = "docs",
    srcs = glob([
        "pages/**/*.mdx",
        "pages/**/*.md",
        "components/**/*.tsx",
        "lib/**/*.ts",
    ]),
    config = "next.config.js",
    theme_config = "theme.config.jsx",
)
```

#### MDX Server

```python
# BUILD.bazel
load("@rules_nextra//nextra:defs.bzl", "nextra_mdx_server")

nextra_mdx_server(
    name = "mdx_server",
    srcs = glob([
        "pages/**/*.mdx",
        "pages/**/*.md",
    ]),
    port = 3001,
    api_prefix = "/api/mdx",
)
```

### 3. Build and Run

```bash
# Build standalone documentation
bazel build //path/to:docs

# Run development server
bazel run //path/to:docs_dev

# Build MDX server
bazel build //path/to:mdx_server

# Run MDX server
bazel run //path/to:mdx_server_server
```

## Configuration

### Standalone Mode Configuration

The standalone mode generates a complete static documentation site. You can customize it with:

#### Next.js Configuration (`next.config.js`)

```javascript
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
```

#### Theme Configuration (`theme.config.jsx`)

```jsx
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
```

### MDX Server Mode Configuration

The MDX server mode provides HTTP endpoints for serving raw MDX content:

#### API Endpoints

- `GET /api/mdx/files` - List all available MDX files
- `GET /api/mdx/{filePath}` - Get raw MDX content for a specific file
- `GET /api/mdx/health` - Health check endpoint

#### Integration with Next.js MDXClient

```typescript
import { MDXClient } from 'next-mdx-remote/rsc';

// Fetch MDX content from the server
const mdxContent = await fetch('http://localhost:3001/api/mdx/api-docs').then(r => r.text());

// Use with MDXClient
return (
  <MDXClient source={mdxContent} />
);
```

## Rule Reference

### nextra_standalone

Creates a standalone Nextra documentation site.

**Attributes:**
- `name` (string, required): Target name
- `srcs` (label_list): Source files (MDX, TS, TSX, etc.)
- `config` (label): Next.js configuration file
- `theme_config` (label): Nextra theme configuration file
- `out_dir` (string, default: "out"): Output directory
- `export_static` (bool, default: True): Whether to export as static site

**Outputs:**
- `out`: Generated static site
- `build_script`: Build script
- `dev_script`: Development script

### nextra_mdx_server

Creates an MDX server for serving raw MDX content.

**Attributes:**
- `name` (string, required): Target name
- `srcs` (label_list): MDX source files
- `port` (int, default: 3001): Server port
- `api_prefix` (string, default: "/api/mdx"): API prefix

**Outputs:**
- `server_script`: Server startup script
- `dev_script`: Development script

## Development Workflow

### Local Development

```bash
# Start development server with hot reload
bazel run //path/to:docs_dev

# Start MDX server in development mode
bazel run //path/to:mdx_server_dev
```

### Building for Production

```bash
# Build standalone documentation
bazel build //path/to:docs

# Build MDX server
bazel build //path/to:mdx_server
```

### Testing

```bash
# Run tests
bazel test //nextra:nextra_tests

# Run linting
bazel run //nextra:nextra_lint

# Run formatting
bazel run //nextra:nextra_format
```

## Examples

See the `examples/` directory for complete working examples:

- `examples/standalone/` - Standalone documentation site
- `examples/mdx-server/` - MDX server implementation

## Integration with Monorepos

### Service/Library Structure

```
my-monorepo/
├── services/
│   ├── api-service/
│   │   ├── BUILD.bazel
│   │   └── docs/
│   │       ├── pages/
│   │       └── theme.config.jsx
│   └── web-service/
│       ├── BUILD.bazel
│       └── docs/
│           ├── pages/
│           └── theme.config.jsx
├── libraries/
│   └── shared-lib/
│       ├── BUILD.bazel
│       └── docs/
│           ├── pages/
│           └── theme.config.jsx
└── WORKSPACE
```

### BUILD.bazel Example

```python
load("@rules_nextra//nextra:defs.bzl", "nextra_standalone")

# Documentation for a service
nextra_standalone(
    name = "api_docs",
    srcs = glob([
        "docs/pages/**/*.mdx",
        "docs/components/**/*.tsx",
    ]),
    config = "docs/next.config.js",
    theme_config = "docs/theme.config.jsx",
    visibility = ["//visibility:public"],
)

# Documentation for a library
nextra_standalone(
    name = "lib_docs",
    srcs = glob([
        "docs/pages/**/*.mdx",
    ]),
    config = "docs/next.config.js",
    theme_config = "docs/theme.config.jsx",
    visibility = ["//visibility:public"],
)
```

## Dependencies

This ruleset requires:

- **aspect-build/rules_ts**: TypeScript support
- **Node.js**: Runtime environment
- **Nextra v4**: Documentation framework
- **Next.js**: React framework
- **Biome**: Linting and formatting (optional)
- **Vitest**: Testing (optional)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

- [GitHub Issues](https://github.com/your-org/rules_nextra/issues)
- [Documentation](https://your-org.github.io/rules_nextra)
- [Examples](https://github.com/your-org/rules_nextra/tree/main/examples)
