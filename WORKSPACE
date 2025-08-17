workspace(name = "rules_nextra")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# Node.js and npm dependencies
http_archive(
    name = "aspect_rules_ts",
    sha256 = "8aabb2055629a7becae2e77ae828950d3581d7fc3602fe0276e6e039b65092cb",
    strip_prefix = "rules_ts-2.0.0",
    url = "https://github.com/aspect-build/rules_ts/releases/download/v2.0.0/rules_ts-v2.0.0.tar.gz",
)

load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_dependencies")
rules_ts_dependencies()

load("@aspect_rules_ts//npm:repositories.bzl", "npm_translate_lock")
npm_translate_lock(
    name = "npm",
    pnpm_lock = "//:pnpm-lock.yaml",
    verify_node_modules_ignored = "//:.bazelignore",
)

# Node.js
http_archive(
    name = "nodejs",
    sha256 = "2f381442381f7fbde2ca644c3275bec9c9c2a8d361f467b40e39428acdd6ccff",
    strip_prefix = "node-v18.17.0-darwin-x64",
    url = "https://nodejs.org/dist/v18.17.0/node-v18.17.0-darwin-x64.tar.gz",
)

# Vitest for testing
http_archive(
    name = "aspect_rules_vitest",
    sha256 = "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5",
    strip_prefix = "rules_vitest-1.0.0",
    url = "https://github.com/aspect-build/rules_vitest/releases/download/v1.0.0/rules_vitest-v1.0.0.tar.gz",
)

load("@aspect_rules_vitest//vitest:repositories.bzl", "rules_vitest_dependencies")
rules_vitest_dependencies()

# Biome for linting/formatting
http_archive(
    name = "aspect_rules_biome",
    sha256 = "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5",
    strip_prefix = "rules_biome-1.0.0",
    url = "https://github.com/aspect-build/rules_biome/releases/download/v1.0.0/rules_biome-v1.0.0.tar.gz",
)

load("@aspect_rules_biome//biome:repositories.bzl", "rules_biome_dependencies")
rules_biome_dependencies()
