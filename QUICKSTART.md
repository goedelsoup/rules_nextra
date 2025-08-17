# Quick Start Guide

Get up and running with Bazel Nextra Documentation Rules in minutes.

## Prerequisites

- Bazel 6.0+
- Node.js 18+
- A monorepo with Bazel setup

## 1. Add to Your WORKSPACE

Add this to your `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Add aspect-build/rules_ts if not already present
http_archive(
    name = "aspect_rules_ts",
    sha256 = "your-sha256-here",
    strip_prefix = "rules_ts-1.0.0",
    url = "https://github.com/aspect-build/rules_ts/releases/download/v1.0.0/rules_ts-v1.0.0.tar.gz",
)

load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_dependencies")
rules_ts_dependencies()

# Add Nextra rules
http_archive(
    name = "rules_nextra",
    sha256 = "your-sha256-here",
    strip_prefix = "rules_nextra-1.0.0",
    url = "https://github.com/your-org/rules_nextra/releases/download/v1.0.0/rules_nextra-v1.0.0.tar.gz",
)

load("@rules_nextra//nextra:defs.bzl", "nextra_standalone", "nextra_mdx_server")
```

## 2. Create Your First Documentation

### Option A: Standalone Documentation Site

Create a `docs/` directory in your service/library:

```
my-service/
├── BUILD.bazel
├── docs/
│   ├── pages/
│   │   ├── index.mdx
│   │   └── getting-started.mdx
│   ├── next.config.js
│   └── theme.config.jsx
```

**BUILD.bazel:**
```python
load("@rules_nextra//nextra:defs.bzl", "nextra_standalone")

nextra_standalone(
    name = "docs",
    srcs = glob([
        "docs/pages/**/*.mdx",
    ]),
    config = "docs/next.config.js",
    theme_config = "docs/theme.config.jsx",
)
```

**docs/pages/index.mdx:**
```markdown
# Welcome to My Service

This is the documentation for my service.

## Quick Start

1. Install the service
2. Configure it
3. Start using it

## Features

- Feature 1
- Feature 2
- Feature 3
```

**docs/next.config.js:**
```javascript
const withNextra = require('nextra')({
  theme: 'nextra-theme-docs',
  themeConfig: './theme.config.jsx',
})

module.exports = withNextra({
  output: 'export',
  trailingSlash: true,
})
```

**docs/theme.config.jsx:**
```jsx
export default {
  logo: <span>My Service</span>,
  project: {
    link: 'https://github.com/your-org/your-repo',
  },
  footer: {
    text: 'MIT 2024 © Your Organization.',
  },
}
```

### Option B: MDX Server

Create an MDX server for remote content consumption:

```
my-service/
├── BUILD.bazel
└── docs/
    └── pages/
        ├── api.mdx
        └── examples.mdx
```

**BUILD.bazel:**
```python
load("@rules_nextra//nextra:defs.bzl", "nextra_mdx_server")

nextra_mdx_server(
    name = "mdx_server",
    srcs = glob([
        "docs/pages/**/*.mdx",
    ]),
    port = 3001,
)
```

**docs/pages/api.mdx:**
```markdown
# API Reference

## Endpoints

### GET /api/users

Returns a list of users.

**Response:**
```json
{
  "users": [
    {"id": 1, "name": "John Doe"}
  ]
}
```
```

## 3. Build and Run

### Standalone Documentation

```bash
# Build the documentation
bazel build //my-service:docs

# Run development server
bazel run //my-service:docs_dev
```

### MDX Server

```bash
# Build the server
bazel build //my-service:mdx_server

# Run the server
bazel run //my-service:mdx_server_server
```

## 4. Access Your Documentation

### Standalone Mode
- Development: http://localhost:3000
- Production: The built files are in `bazel-bin/my-service/docs_out/`

### MDX Server Mode
- Server: http://localhost:3001
- API: http://localhost:3001/api/mdx/files
- Content: http://localhost:3001/api/mdx/api

## 5. Integration with Next.js MDXClient

If using MDX Server mode, integrate with your Next.js app:

```typescript
import { MDXClient } from 'next-mdx-remote/rsc';

async function DocumentationPage({ params }: { params: { slug: string } }) {
  const response = await fetch(`http://localhost:3001/api/mdx/${params.slug}`);
  const mdxContent = await response.text();
  
  return <MDXClient source={mdxContent} />;
}
```

## Common Commands

```bash
# Build documentation
bazel build //path/to:docs

# Run development server
bazel run //path/to:docs_dev

# Build MDX server
bazel build //path/to:mdx_server

# Run MDX server
bazel run //path/to:mdx_server_server

# Run tests
bazel test //nextra:nextra_tests

# Lint code
bazel run //nextra:nextra_lint

# Format code
bazel run //nextra:nextra_format
```

## Next Steps

- Read the [full documentation](README.md)
- Check out the [examples](examples/)
- Learn about the [MDX Server API](docs/mdx-server-api.md)
- Explore [advanced configuration](README.md#configuration)

## Troubleshooting

### Common Issues

1. **"Module not found" errors**: Ensure all dependencies are properly declared in your `package.json`
2. **Port conflicts**: Change the port in your BUILD.bazel file
3. **Build failures**: Check that all source files are included in the `srcs` attribute

### Getting Help

- [GitHub Issues](https://github.com/your-org/rules_nextra/issues)
- [Documentation](README.md)
- [Examples](examples/)
