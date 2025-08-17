# MDX Server API Documentation

The MDX Server mode provides HTTP endpoints for serving raw MDX content, making it consumable by Next.js applications using MDXClient.

## API Endpoints

### GET /api/mdx/files

Returns a list of all available MDX files in the server.

**Response:**
```json
{
  "files": [
    {
      "path": "getting-started",
      "extension": ".mdx",
      "size": 1024,
      "modified": "2024-01-01T00:00:00.000Z"
    },
    {
      "path": "api/endpoints",
      "extension": ".md",
      "size": 2048,
      "modified": "2024-01-02T00:00:00.000Z"
    }
  ]
}
```

**Use Case:** Discover available documentation files for dynamic navigation or content listing.

### GET /api/mdx/{filePath}

Returns the raw MDX content for a specific file.

**Parameters:**
- `filePath` (string): The path to the MDX file (without extension)

**Response Headers:**
- `Content-Type: text/markdown`
- `X-File-Extension: .mdx` (or `.md`)

**Response Body:**
Raw MDX content as plain text.

**Example Request:**
```
GET /api/mdx/getting-started
```

**Example Response:**
```
# Getting Started

Welcome to our documentation!

## Installation

```bash
npm install my-package
```

## Usage

```typescript
import { MyComponent } from 'my-package';
```
```

**Use Case:** Fetch MDX content for rendering in a Next.js application using MDXClient.

### GET /api/mdx/health

Health check endpoint for monitoring and load balancers.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Integration with Next.js MDXClient

### Basic Integration

```typescript
import { MDXClient } from 'next-mdx-remote/rsc';

async function DocumentationPage({ params }: { params: { slug: string } }) {
  // Fetch MDX content from the server
  const response = await fetch(`http://localhost:3001/api/mdx/${params.slug}`);
  
  if (!response.ok) {
    throw new Error('Failed to fetch documentation');
  }
  
  const mdxContent = await response.text();
  
  return (
    <div className="documentation">
      <MDXClient source={mdxContent} />
    </div>
  );
}
```

### Advanced Integration with Error Handling

```typescript
import { MDXClient } from 'next-mdx-remote/rsc';
import { notFound } from 'next/navigation';

async function DocumentationPage({ params }: { params: { slug: string } }) {
  try {
    const response = await fetch(`http://localhost:3001/api/mdx/${params.slug}`, {
      headers: {
        'Accept': 'text/markdown',
      },
    });
    
    if (response.status === 404) {
      notFound();
    }
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const mdxContent = await response.text();
    const fileExtension = response.headers.get('X-File-Extension');
    
    return (
      <div className="documentation">
        <MDXClient source={mdxContent} />
        {fileExtension && (
          <div className="file-info">
            File type: {fileExtension}
          </div>
        )}
      </div>
    );
  } catch (error) {
    console.error('Error fetching documentation:', error);
    throw new Error('Failed to load documentation');
  }
}
```

### Dynamic Navigation

```typescript
import Link from 'next/link';

async function DocumentationNav() {
  // Fetch available files for navigation
  const response = await fetch('http://localhost:3001/api/mdx/files');
  const { files } = await response.json();
  
  return (
    <nav className="docs-nav">
      <ul>
        {files.map((file) => (
          <li key={file.path}>
            <Link href={`/docs/${file.path}`}>
              {file.path.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
```

## Configuration

### Server Configuration

```python
# BUILD.bazel
load("@rules_nextra//nextra:defs.bzl", "nextra_mdx_server")

nextra_mdx_server(
    name = "mdx_server",
    srcs = glob([
        "pages/**/*.mdx",
        "pages/**/*.md",
    ]),
    port = 3001,  # Customize port
    api_prefix = "/api/mdx",  # Customize API prefix
)
```

### Environment Variables

The MDX server respects the following environment variables:

- `PORT`: Server port (default: 3001)
- `NODE_ENV`: Environment mode (development/production)

### CORS Configuration

The MDX server includes CORS support for cross-origin requests. In production, you may want to configure specific origins:

```typescript
// Custom CORS configuration
app.use(cors({
  origin: ['https://your-domain.com', 'http://localhost:3000'],
  methods: ['GET'],
  allowedHeaders: ['Content-Type'],
}));
```

## Error Handling

### Common Error Responses

**404 Not Found:**
```json
{
  "error": "File not found",
  "path": "non-existent-file"
}
```

**500 Internal Server Error:**
```json
{
  "error": "Internal server error",
  "message": "Error details"
}
```

### Client-Side Error Handling

```typescript
async function fetchMDXContent(filePath: string) {
  try {
    const response = await fetch(`http://localhost:3001/api/mdx/${filePath}`);
    
    if (response.status === 404) {
      return { error: 'Documentation not found' };
    }
    
    if (!response.ok) {
      return { error: 'Failed to fetch documentation' };
    }
    
    const content = await response.text();
    return { content };
  } catch (error) {
    return { error: 'Network error' };
  }
}
```

## Performance Considerations

### Caching

Consider implementing caching strategies:

```typescript
// Client-side caching
const cache = new Map();

async function fetchMDXWithCache(filePath: string) {
  if (cache.has(filePath)) {
    return cache.get(filePath);
  }
  
  const content = await fetchMDXContent(filePath);
  cache.set(filePath, content);
  return content;
}
```

### Load Balancing

For production deployments, consider:

1. **Multiple Instances**: Run multiple MDX server instances behind a load balancer
2. **Health Checks**: Use the `/api/mdx/health` endpoint for health monitoring
3. **CDN**: Cache static MDX content at the CDN level

## Security Considerations

1. **Input Validation**: The server validates file paths to prevent directory traversal attacks
2. **CORS**: Configure appropriate CORS policies for your domain
3. **Rate Limiting**: Consider implementing rate limiting for production use
4. **Authentication**: Add authentication if serving sensitive documentation

## Monitoring

### Health Checks

Monitor the health endpoint:

```bash
curl http://localhost:3001/api/mdx/health
```

### Metrics

Consider adding metrics collection:

```typescript
// Example with basic metrics
let requestCount = 0;

app.use((req, res, next) => {
  requestCount++;
  console.log(`Request ${requestCount}: ${req.method} ${req.path}`);
  next();
});
```

## Troubleshooting

### Common Issues

1. **File Not Found**: Ensure MDX files are included in the `srcs` attribute
2. **Port Conflicts**: Change the port if 3001 is already in use
3. **CORS Errors**: Check CORS configuration for cross-origin requests
4. **Content-Type Issues**: Verify the server returns `text/markdown` content type

### Debug Mode

Enable debug logging by setting `NODE_ENV=development`:

```bash
NODE_ENV=development bazel run //path/to:mdx_server_server
```
