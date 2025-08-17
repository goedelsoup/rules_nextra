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
rules_ts_dependencies(ts_version = "5.1.5")

# Note: npm_translate_lock is not available in aspect_rules_ts v2.0.0
# We'll use a simpler approach for now

# Node.js toolchain
load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_bazel_dependencies")
rules_ts_bazel_dependencies()

# Note: Node.js toolchain is handled by aspect_rules_ts


