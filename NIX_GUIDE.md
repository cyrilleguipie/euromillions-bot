# Nix Development Guide

## Overview

The project uses Nix flakes with:
- **rust-overlay**: Custom Rust toolchain from `rust-toolchain.toml`
- **crane**: Efficient Rust builds with better caching
- **Cargo tools**: Comprehensive development tooling

## Quick Start

```bash
# Enter dev shell
nix develop

# Or use direnv
direnv allow
```

## Available Commands

### Development
```bash
# Run with auto-reload
cargo watch -x run

# Expand macros
cargo expand

# Check for vulnerabilities
cargo audit

# Update dependencies
cargo upgrade

# Check outdated deps
cargo outdated

# Code coverage
cargo tarpaulin
```

### Building
```bash
# Build binary
nix build

# Build Docker image
nix build .#docker

# Load Docker image
docker load < result
```

### Checks (CI)
```bash
# Run all checks
nix flake check

# Individual checks
nix build .#checks.euromillions-clippy
nix build .#checks.euromillions-fmt
nix build .#checks.euromillions-audit
```

## Structure

- `rust-toolchain.toml`: Rust version and components
- `flake.nix`: Nix configuration with crane builder
- `.envrc`: Direnv integration

## Benefits

1. **Reproducible builds**: Same environment everywhere
2. **Better caching**: Crane separates dependency and source builds
3. **CI/CD ready**: Built-in checks for clippy, fmt, audit
4. **Docker integration**: `nix build .#docker` creates image
5. **Developer tools**: All cargo extensions pre-installed

## Customization

### Adding Cargo Tools

Edit `flake.nix`:
```nix
cargoTools = with pkgs; [
  rust-analyzer
  cargo-expand
  # Add more here
];
```

### Changing Rust Version

Edit `rust-toolchain.toml`:
```toml
[toolchain]
channel = "1.75.0"  # or "stable", "nightly"
```
