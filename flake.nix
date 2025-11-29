{
  description = "Euromillions Bot - Lottery grid generator using historical data";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        
        # Load rust toolchain from rust-toolchain.toml
        rustToolchainPath = ./rust-toolchain.toml;
        rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile rustToolchainPath;

        customRustOverlay = final: prev: {
          fixedRust = rustToolchain.override {
            extensions = [ "rust-src" "rust-analyzer" ];
            targets = [ ];
          };
        };

        pkgsWithRust = pkgs.extend customRustOverlay;

        # Crane lib configured with our custom Rust toolchain
        craneLib = (crane.mkLib pkgs).overrideToolchain pkgsWithRust.fixedRust;

        # Common build inputs
        commonArgs = {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

          buildInputs = with pkgs; [
            openssl
            postgresql
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.SystemConfiguration
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          # Enable SQLx offline mode
          SQLX_OFFLINE = "true";
        };

        # Build dependencies separately for better caching
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        # Build the actual binary
        euromillionsBot = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;
          
          meta = with pkgs.lib; {
            description = "Euromillions lottery grid generator using historical statistics";
            homepage = "https://github.com/cyrilleguipie/euromillions-bot";
            license = licenses.mit;
          };
        });

        # Docker image
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "euromillions-bot";
          tag = "latest";
          
          contents = with pkgs; [
            euromillionsBot
            cacert
            bash
            coreutils
          ];

          config = {
            Cmd = [ "${euromillionsBot}/bin/euromillions_bot" ];
            ExposedPorts = {
              "8080/tcp" = {};
            };
            Env = [
              "RUST_LOG=info"
            ];
          };
        };

        # Cargo tools
        cargoTools = with pkgs; [
          rust-analyzer
          cargo-expand
          cargo-audit
          cargo-edit
          cargo-outdated
          cargo-watch
          cargo-tarpaulin
        ];

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          inputsFrom = [ euromillionsBot ];
          
          packages = with pkgs; [
            # Rust toolchain with extras
            pkgsWithRust.fixedRust
            
            # Cargo tools
          ] ++ cargoTools ++ [
            # Database
            postgresql
            sqlx-cli
            
            # Node.js for web frontend
            nodejs_20
            
            # Container tools
            docker-compose
            
            # Utilities
            jq
            curl
          ];

          shellHook = ''
            echo "🎰 Euromillions Bot Dev Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Rust:       $(rustc --version)"
            echo "Cargo:      $(cargo --version)"
            echo "Node.js:    $(node --version)"
            echo "PostgreSQL: $(psql --version | head -n1)"
            echo ""
            echo "📦 Available tools:"
            echo "  cargo-watch, cargo-expand, cargo-audit"
            echo "  cargo-edit, cargo-outdated, cargo-tarpaulin"
            echo ""
            echo "🚀 Commands:"
            echo "  cargo run          - Run the bot API"
            echo "  cargo watch -x run - Auto-reload on changes"
            echo "  docker-compose up  - Start full stack (API + Web + DB)"
            echo "  cd web && npm run dev - Run web frontend"
            echo "  nix build          - Build binary"
            echo "  nix build .#docker - Build Docker image"
            echo ""
            
            export DATABASE_URL="postgres://user:password@localhost:5432/euromillions_bot"
            export RUST_LOG="info"
            export RUST_BACKTRACE="1"
          '';
        };

        # Packages
        packages = {
          default = euromillionsBot;
          docker = dockerImage;
        };

        # Apps
        apps.default = flake-utils.lib.mkApp {
          drv = euromillionsBot;
        };

        # Checks (for CI)
        checks = {
          inherit euromillionsBot;
          
          # Clippy check
          euromillions-clippy = craneLib.cargoClippy (commonArgs // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          });

          # Format check
          euromillions-fmt = craneLib.cargoFmt {
            inherit (commonArgs) src;
          };

          # Audit dependencies
          euromillions-audit = craneLib.cargoAudit {
            inherit (commonArgs) src;
            advisory-db = pkgs.fetchFromGitHub {
              owner = "rustsec";
              repo = "advisory-db";
              rev = "main";
              sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            };
          };
        };
      }
    );
}
