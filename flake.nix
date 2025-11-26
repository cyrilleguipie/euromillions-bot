{
  description = "Euromillions Bot - Lottery grid generator using historical data";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        nativeBuildInputs = with pkgs; [
          rustToolchain
          pkg-config
        ];

        buildInputs = with pkgs; [
          openssl
          postgresql
        ] ++ lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
          
          packages = with pkgs; [
            # Database tools
            postgresql
            sqlx-cli
            
            # Development tools
            cargo-watch
            docker-compose
            
            # Utilities
            jq
            curl
          ];

          shellHook = ''
            echo "🎰 Euromillions Bot Dev Environment"
            echo "Rust version: $(rustc --version)"
            echo "PostgreSQL: $(psql --version | head -n1)"
            echo ""
            echo "Available commands:"
            echo "  cargo run          - Run the bot"
            echo "  docker-compose up  - Start with Docker"
            echo "  sqlx migrate run   - Run database migrations"
            echo ""
            
            export DATABASE_URL="postgres://user:password@localhost:5432/euromillions_bot"
            export RUST_LOG="info"
          '';
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "euromillions_bot";
          version = "0.1.0";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = nativeBuildInputs;
          buildInputs = buildInputs;

          # Enable SQLx offline mode for build
          SQLX_OFFLINE = "true";

          meta = with pkgs.lib; {
            description = "Euromillions lottery grid generator using historical statistics";
            homepage = "https://github.com/cyrilleguipie/euromillions-bot";
            license = licenses.mit;
            maintainers = [ ];
          };
        };
      }
    );
}
