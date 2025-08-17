"""
Bazel rules for Nextra v4 documentation sites.

This module provides rules for creating Nextra documentation sites in two modes:
1. Standalone Server Mode: Complete static documentation site
2. MDX Server Mode: HTTP server serving raw MDX content
"""

load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@aspect_rules_ts//npm:defs.bzl", "npm_package")
load("@aspect_rules_ts//npm:defs.bzl", "npm_package_bin")
load("//nextra:private/nextra_standalone.bzl", "nextra_standalone_impl")
load("//nextra:private/nextra_mdx_server.bzl", "nextra_mdx_server_impl")
load("//nextra:private/nextra_common.bzl", "nextra_common_attrs")

# Standalone Nextra documentation site
nextra_standalone = rule(
    implementation = nextra_standalone_impl,
    attrs = nextra_common_attrs + {
        "out_dir": attr.string(
            default = "out",
            doc = "Output directory for the static site",
        ),
        "export_static": attr.bool(
            default = True,
            doc = "Whether to export as static site",
        ),
    },
    outputs = {
        "out": "%{name}_out",
        "build_script": "%{name}_build.sh",
        "dev_script": "%{name}_dev.sh",
    },
    doc = """
    Creates a standalone Nextra documentation site.
    
    This rule generates a complete static documentation site that can be deployed independently.
    It includes all necessary assets, HTML, CSS, and JavaScript for a self-contained docs site.
    
    Example:
        nextra_standalone(
            name = "docs",
            srcs = glob(["pages/**/*.mdx"]),
            config = "next.config.js",
            theme_config = "theme.config.jsx",
        )
    """,
)

# MDX Server for serving raw MDX content
nextra_mdx_server = rule(
    implementation = nextra_mdx_server_impl,
    attrs = nextra_common_attrs + {
        "port": attr.int(
            default = 3001,
            doc = "Port for the MDX server",
        ),
        "api_prefix": attr.string(
            default = "/api/mdx",
            doc = "API prefix for MDX endpoints",
        ),
    },
    outputs = {
        "server_script": "%{name}_server.sh",
        "dev_script": "%{name}_dev.sh",
    },
    doc = """
    Creates an MDX server that serves raw MDX content via HTTP.
    
    This rule creates an HTTP server that serves MDX files over HTTP endpoints,
    consumable by Next.js applications using MDXClient.
    
    Example:
        nextra_mdx_server(
            name = "mdx_server",
            srcs = glob(["pages/**/*.mdx"]),
            port = 3001,
        )
    """,
)

# Common Nextra project setup
def nextra_project(
        name,
        srcs = None,
        config = None,
        theme_config = None,
        **kwargs):
    """
    Sets up a complete Nextra project with TypeScript support.
    
    Args:
        name: Name of the project
        srcs: Source files (MDX, JS, TS, etc.)
        config: Next.js configuration file
        theme_config: Nextra theme configuration file
        **kwargs: Additional arguments passed to underlying rules
    """
    
    # TypeScript project for Nextra
    ts_project(
        name = name + "_ts",
        srcs = srcs or native.glob([
            "pages/**/*.ts",
            "pages/**/*.tsx",
            "components/**/*.ts",
            "components/**/*.tsx",
            "lib/**/*.ts",
            "lib/**/*.tsx",
        ]),
        declaration = True,
        tsconfig = "//:tsconfig.json",
        deps = [
            "//:node_modules/next",
            "//:node_modules/react",
            "//:node_modules/react-dom",
            "//:node_modules/nextra",
            "//:node_modules/nextra-theme-docs",
        ],
        **kwargs
    )
    
    # NPM package for the project
    npm_package(
        name = name + "_package",
        srcs = srcs or native.glob([
            "pages/**/*",
            "components/**/*",
            "lib/**/*",
            "public/**/*",
        ]),
        package = "package.json",
        **kwargs
    )
