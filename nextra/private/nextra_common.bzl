"""
Common utilities and attributes for Nextra rules.
"""

load("@aspect_rules_ts//npm:defs.bzl", "npm_package_bin")

# Common attributes for Nextra rules
nextra_common_attrs = {
    "srcs": attr.label_list(
        allow_files = [".mdx", ".md", ".ts", ".tsx", ".js", ".jsx", ".json"],
        doc = "Source files for the Nextra project",
    ),
    "config": attr.label(
        allow_single_file = [".js", ".ts"],
        doc = "Next.js configuration file",
    ),
    "theme_config": attr.label(
        allow_single_file = [".js", ".jsx", ".ts", ".tsx"],
        doc = "Nextra theme configuration file",
    ),
    "package_json": attr.label(
        default = "//:package.json",
        allow_single_file = True,
        doc = "Package.json file for the project",
    ),
    "data": attr.label_list(
        allow_files = True,
        doc = "Additional data files",
    ),
    "deps": attr.label_list(
        doc = "Additional dependencies",
    ),
    "visibility": attr.string_list(
        default = ["//visibility:public"],
        doc = "Visibility of the target",
    ),
}

def create_nextra_config(ctx, config_content = None):
    """
    Creates a Nextra configuration file.
    
    Args:
        ctx: The rule context
        config_content: Custom configuration content
    
    Returns:
        The configuration file path
    """
    
    if config_content:
        config_file = ctx.actions.declare_file(ctx.label.name + "_next.config.js")
        ctx.actions.write(
            output = config_file,
            content = config_content,
        )
        return config_file
    
    # Default Nextra configuration
    default_config = """
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
"""
    
    config_file = ctx.actions.declare_file(ctx.label.name + "_next.config.js")
    ctx.actions.write(
        output = config_file,
        content = default_config,
    )
    return config_file

def create_theme_config(ctx, theme_content = None):
    """
    Creates a Nextra theme configuration file.
    
    Args:
        ctx: The rule context
        theme_content: Custom theme configuration content
    
    Returns:
        The theme configuration file path
    """
    
    if theme_content:
        theme_file = ctx.actions.declare_file(ctx.label.name + "_theme.config.jsx")
        ctx.actions.write(
            output = theme_file,
            content = theme_content,
        )
        return theme_file
    
    # Default theme configuration
    default_theme = """
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
"""
    
    theme_file = ctx.actions.declare_file(ctx.label.name + "_theme.config.jsx")
    ctx.actions.write(
        output = theme_file,
        content = default_theme,
    )
    return theme_file

def get_nextra_bin(ctx):
    """
    Gets the Nextra binary for building and development.
    
    Args:
        ctx: The rule context
    
    Returns:
        The Nextra binary target
    """
    return npm_package_bin(
        name = ctx.label.name + "_nextra_bin",
        package = "nextra",
        binary = "nextra",
        data = [ctx.file.package_json],
    )
