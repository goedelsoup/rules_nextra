"""
Implementation for MDX server rule.
"""

load("@aspect_rules_ts//npm:defs.bzl", "npm_package_bin")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")

def nextra_mdx_server_impl(ctx):
    """
    Implementation for nextra_mdx_server rule.
    
    Creates an HTTP server that serves raw MDX content over HTTP endpoints,
    consumable by Next.js applications using MDXClient.
    """
    
    # Collect all MDX files
    mdx_files = []
    for src in ctx.attr.srcs:
        for file in src.files.to_list():
            if file.extension in ["mdx", "md"]:
                mdx_files.append(file)
    
    # Create TypeScript server implementation
    server_ts = ctx.actions.declare_file(ctx.label.name + "_server.ts")
    server_content = """
import express from 'express';
import { readFileSync, existsSync } from 'fs';
import { join, extname } from 'path';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || {};

// Enable CORS for cross-origin requests
app.use(cors());

// Parse JSON bodies
app.use(express.json());

// Serve MDX files
app.get('{}/*', (req, res) => {{
    const filePath = req.params[0];
    const fullPath = join(__dirname, 'mdx', filePath);
    
    // Try different extensions
    const extensions = ['.mdx', '.md'];
    let content = null;
    let foundExtension = null;
    
    for (const ext of extensions) {{
        const testPath = fullPath + ext;
        if (existsSync(testPath)) {{
            try {{
                content = readFileSync(testPath, 'utf-8');
                foundExtension = ext;
                break;
            }} catch (error) {{
                console.error('Error reading file:', testPath, error);
            }}
        }}
    }}
    
    if (content) {{
        res.setHeader('Content-Type', 'text/markdown');
        res.setHeader('X-File-Extension', foundExtension);
        res.send(content);
    }} else {{
        res.status(404).json({{ error: 'File not found', path: filePath }});
    }}
}});

// List available MDX files
app.get('{}/files', (req, res) => {{
    const mdxDir = join(__dirname, 'mdx');
    const files = [];
    
    function scanDirectory(dir, prefix = '') {{
        try {{
            const items = readdirSync(dir);
            for (const item of items) {{
                const fullPath = join(dir, item);
                const stat = statSync(fullPath);
                
                if (stat.isDirectory()) {{
                    scanDirectory(fullPath, join(prefix, item));
                }} else if (extname(item) === '.mdx' || extname(item) === '.md') {{
                    const relativePath = join(prefix, item.replace(/\\.(mdx|md)$/, ''));
                    files.push({{
                        path: relativePath,
                        extension: extname(item),
                        size: stat.size,
                        modified: stat.mtime
                    }});
                }}
            }}
        }} catch (error) {{
            console.error('Error scanning directory:', dir, error);
        }}
    }}
    
    scanDirectory(mdxDir);
    res.json({{ files }});
}});

// Health check endpoint
app.get('{}/health', (req, res) => {{
    res.json({{ status: 'ok', timestamp: new Date().toISOString() }});
}});

// Start server
app.listen(PORT, () => {{
    console.log(`MDX Server running on port ${{PORT}}`);
    console.log(`API prefix: {}`);
}});
""".format(
        ctx.attr.port,
        ctx.attr.api_prefix,
        ctx.attr.api_prefix,
        ctx.attr.api_prefix,
        ctx.attr.api_prefix,
    )
    
    ctx.actions.write(
        output = server_ts,
        content = server_content,
    )
    
    # Create package.json for the server
    server_package_json = ctx.actions.declare_file(ctx.label.name + "_package.json")
    server_package_content = """{
  "name": "nextra-mdx-server",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "ts-node server.ts"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "@types/cors": "^2.8.0",
    "ts-node": "^10.9.0",
    "typescript": "^5.0.0"
  }
}"""
    
    ctx.actions.write(
        output = server_package_json,
        content = server_package_content,
    )
    
    # Create server script
    server_script = ctx.actions.declare_file(ctx.label.name + "_server.sh")
    server_content = """#!/bin/bash
set -e

# Set up environment
export PORT={}

# Create MDX directory and copy files
mkdir -p mdx
""".format(ctx.attr.port)
    
    # Copy MDX files
    for mdx_file in mdx_files:
        server_content += "cp '{}' mdx/\n".format(mdx_file.path)
    
    server_content += """
# Copy server files
cp '{}' server.ts
cp '{}' package.json

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    npm install
fi

# Start the server
npx ts-node server.ts
""".format(server_ts.path, server_package_json.path)
    
    ctx.actions.write(
        output = server_script,
        content = server_content,
        is_executable = True,
    )
    
    # Create development script
    dev_script = ctx.actions.declare_file(ctx.label.name + "_dev.sh")
    dev_content = """#!/bin/bash
set -e

# Set up environment
export PORT={}
export NODE_ENV=development

# Create MDX directory and copy files
mkdir -p mdx
""".format(ctx.attr.port)
    
    # Copy MDX files for dev
    for mdx_file in mdx_files:
        dev_content += "cp '{}' mdx/\n".format(mdx_file.path)
    
    dev_content += """
# Copy server files
cp '{}' server.ts
cp '{}' package.json

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    npm install
fi

# Start the development server with watch mode
npx ts-node-dev --respawn server.ts
""".format(server_ts.path, server_package_json.path)
    
    ctx.actions.write(
        output = dev_script,
        content = dev_content,
        is_executable = True,
    )
    
    # Create TypeScript project for the server
    ts_project(
        name = ctx.label.name + "_server_ts",
        srcs = [server_ts],
        declaration = True,
        tsconfig = "//:tsconfig.json",
        deps = [
            "//:node_modules/express",
            "//:node_modules/cors",
            "//:node_modules/@types/express",
            "//:node_modules/@types/cors",
        ],
    )
    
    return [
        DefaultInfo(
            files = depset(mdx_files),
            runfiles = ctx.runfiles(files = mdx_files),
        ),
        OutputGroupInfo(
            server_script = depset([server_script]),
            dev_script = depset([dev_script]),
            mdx_files = depset(mdx_files),
        ),
    ]
