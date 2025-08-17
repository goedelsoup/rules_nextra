# CI Setup Guide

This document describes the CI setup for the rules_nextra project and how to resolve common issues.

## Current CI Status

The GitHub Actions CI workflow is set up in `.github/workflows/ci.yml` and includes:

### ✅ Working Components
- **Node.js setup** with pnpm package manager
- **Linting** with Biome (`pnpm run lint`)
- **Formatting checks** with Biome (`pnpm run format --check`)
- **Unit tests** with Vitest (`pnpm run test`)
- **Type checking** with TypeScript (`pnpm run build`)

### ⚠️ Bazel Components (Need Configuration)
- **Bazel linting** (`bazel run //:workspace_lint`)
- **Bazel formatting** (`bazel run //:workspace_format`)
- **Bazel tests** (`bazel test //:workspace_tests`)
- **Bazel builds** (`bazel build //:all`)
- **Example builds** and integration tests

## Issue: WORKSPACE Configuration

The Bazel components are currently failing because the `WORKSPACE` file contains placeholder SHA256 values. To fix this:

### Step 1: Get Correct SHA256 Values

Run the provided script to get the correct SHA256 values:

```bash
./scripts/get-sha256.sh
```

### Step 2: Update WORKSPACE File

Replace the placeholder SHA256 values in `WORKSPACE` with the actual values from the script:

```python
# Example (replace with actual values from the script)
http_archive(
    name = "aspect_rules_ts",
    sha256 = "actual_sha256_value_here",
    strip_prefix = "rules_ts-2.0.0",
    url = "https://github.com/aspect-build/rules_ts/releases/download/v2.0.0/rules_ts-v2.0.0.tar.gz",
)
```

### Step 3: Test Locally

After updating the WORKSPACE file, test the Bazel commands locally:

```bash
# Test Bazel linting
bazel run //:workspace_lint

# Test Bazel formatting
bazel run //:workspace_format

# Test Bazel tests
bazel test //:workspace_tests

# Test Bazel builds
bazel build //:all
```

## CI Workflow Details

### Triggers
- **Push** to `main` branch
- **Pull Request** to `main` branch (opened and synchronized)

### Steps
1. **Checkout** code
2. **Setup Node.js** (v18) with npm caching
3. **Setup pnpm** package manager
4. **Install dependencies** with frozen lockfile
5. **Run linting** (Biome)
6. **Check formatting** (Biome)
7. **Run tests** (Vitest)
8. **Type check** (TypeScript)
9. **Setup Bazel** (bazelisk)
10. **Bazel operations** (with continue-on-error for now)

### Current Behavior
- Node.js operations (linting, formatting, tests, type checking) are **required** and will fail the CI if they don't pass
- Bazel operations are **optional** (continue-on-error: true) until the WORKSPACE file is properly configured

## Next Steps

1. **Fix WORKSPACE file** with correct SHA256 values
2. **Test Bazel commands** locally
3. **Remove continue-on-error** from Bazel steps in CI
4. **Add more comprehensive testing** as needed

## Troubleshooting

### Common Issues

1. **SHA256 mismatch**: Use the provided script to get correct values
2. **Repository not found**: Check that the URLs in WORKSPACE are correct
3. **Bazel version issues**: The CI uses bazelisk which automatically selects the correct Bazel version

### Local Development

For local development, ensure you have:
- Node.js 18+
- pnpm
- Bazel (or bazelisk)

Then run:
```bash
pnpm install
pnpm run lint
pnpm run format --check
pnpm run test
pnpm run build
```

## Files Created/Modified

- `.github/workflows/ci.yml` - GitHub Actions workflow
- `.bazelignore` - Bazel ignore file
- `scripts/get-sha256.sh` - Script to get SHA256 values
- `package.json` - Added build script
- `README.md` - Updated with CI documentation
- `CI_SETUP.md` - This guide
