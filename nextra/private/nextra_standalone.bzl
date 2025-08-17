"""
Implementation for standalone Nextra documentation site rule.
"""

load("@aspect_rules_ts//npm:defs.bzl", "npm_package_bin")
load("//nextra:private/nextra_common.bzl", "create_nextra_config", "create_theme_config")

def nextra_standalone_impl(ctx):
    """
    Implementation for nextra_standalone rule.
    
    Creates a standalone Nextra documentation site that can be deployed independently.
    """
    
    # Get or create configuration files
    config_file = ctx.file.config if ctx.file.config else create_nextra_config(ctx)
    theme_file = ctx.file.theme_config if ctx.file.theme_config else create_theme_config(ctx)
    
    # Get Nextra binary
    nextra_bin = npm_package_bin(
        name = ctx.label.name + "_nextra_bin",
        package = "nextra",
        binary = "nextra",
        data = [ctx.file.package_json],
    )
    
    # Get Next.js binary for building
    next_bin = npm_package_bin(
        name = ctx.label.name + "_next_bin",
        package = "next",
        binary = "next",
        data = [ctx.file.package_json],
    )
    
    # Collect all source files
    src_files = []
    for src in ctx.attr.srcs:
        src_files.extend(src.files.to_list())
    
    # Create build script
    build_script = ctx.actions.declare_file(ctx.label.name + "_build.sh")
    build_content = """#!/bin/bash
set -e

# Set up environment
export NODE_ENV=production

# Copy source files to working directory
mkdir -p pages components lib public
"""
    
    # Copy source files
    for src_file in src_files:
        if src_file.extension in ["mdx", "md"]:
            build_content += "cp '{}' pages/\n".format(src_file.path)
        elif src_file.extension in ["ts", "tsx", "js", "jsx"]:
            if "components" in src_file.path:
                build_content += "cp '{}' components/\n".format(src_file.path)
            elif "lib" in src_file.path:
                build_content += "cp '{}' lib/\n".format(src_file.path)
            else:
                build_content += "cp '{}' pages/\n".format(src_file.path)
        elif src_file.extension in ["json", "css", "png", "jpg", "jpeg", "gif", "svg"]:
            build_content += "cp '{}' public/\n".format(src_file.path)
    
    build_content += """
# Copy configuration files
cp '{}' next.config.js
cp '{}' theme.config.jsx

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    npm install
fi

# Build the static site
if [ "{}" = "True" ]; then
    npx next build
    npx next export -o {}
else
    npx next build
fi

# Copy output to Bazel output directory
mkdir -p $1
cp -r {}/* $1/ 2>/dev/null || cp -r .next/* $1/ 2>/dev/null || true
""".format(
        config_file.path,
        theme_file.path,
        str(ctx.attr.export_static),
        ctx.attr.out_dir,
        ctx.attr.out_dir,
    )
    
    ctx.actions.write(
        output = build_script,
        content = build_content,
        is_executable = True,
    )
    
    # Create development script
    dev_script = ctx.actions.declare_file(ctx.label.name + "_dev.sh")
    dev_content = """#!/bin/bash
set -e

# Set up environment
export NODE_ENV=development

# Copy source files to working directory
mkdir -p pages components lib public
"""
    
    # Copy source files for dev
    for src_file in src_files:
        if src_file.extension in ["mdx", "md"]:
            dev_content += "cp '{}' pages/\n".format(src_file.path)
        elif src_file.extension in ["ts", "tsx", "js", "jsx"]:
            if "components" in src_file.path:
                dev_content += "cp '{}' components/\n".format(src_file.path)
            elif "lib" in src_file.path:
                dev_content += "cp '{}' lib/\n".format(src_file.path)
            else:
                dev_content += "cp '{}' pages/\n".format(src_file.path)
        elif src_file.extension in ["json", "css", "png", "jpg", "jpeg", "gif", "svg"]:
            dev_content += "cp '{}' public/\n".format(src_file.path)
    
    dev_content += """
# Copy configuration files
cp '{}' next.config.js
cp '{}' theme.config.jsx

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    npm install
fi

# Start development server
npx next dev --port 3000
""".format(config_file.path, theme_file.path)
    
    ctx.actions.write(
        output = dev_script,
        content = dev_content,
        is_executable = True,
    )
    
    # Create output directory
    out_dir = ctx.actions.declare_directory(ctx.label.name + "_out")
    
    # Run build action
    ctx.actions.run(
        outputs = [out_dir],
        inputs = src_files + [config_file, theme_file, ctx.file.package_json],
        tools = [nextra_bin, next_bin],
        executable = build_script,
        arguments = [out_dir.path],
        mnemonic = "NextraBuild",
        progress_message = "Building Nextra documentation site",
    )
    
    return [
        DefaultInfo(
            files = depset([out_dir]),
            runfiles = ctx.runfiles(files = [out_dir]),
        ),
        OutputGroupInfo(
            out = depset([out_dir]),
            build_script = depset([build_script]),
            dev_script = depset([dev_script]),
        ),
    ]
