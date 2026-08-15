{
  description = "comview — a terminal unified diff viewer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = rec {
        default = comview;

        comview = pkgs.buildGoModule {
          pname = "comview";
          version = "unstable-2026-08-15"; # update to a real tag/commit when you release

          src = ./.;

          # go 1.26.1 is required; go_1_26 is available on nixos-unstable
          go = pkgs.go_1_26;

          # The sub-package that produces the binary
          subPackages = ["cmd/comview"];

          # Start with a fake hash, then let `nix build` tell you the real one
          vendorHash = "sha256-f7Q4+Bd22xnxkOWjgv4TzPmgZTNHhYvMtoVyl9anGzc=";

          # Run tests during the build
          doCheck = true;

          meta = with pkgs.lib; {
            description = "A terminal unified diff viewer with vim-like keybinds";
            homepage = "https://github.com/rockorager/comview";
            license = licenses.mit;
            mainProgram = "comview";
            platforms = platforms.linux ++ platforms.darwin;
          };
        };
      };

      # Expose a dev shell with Go and common tools
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go_1_26
          gopls
          gofumpt
          golangci-lint
          mise
        ];
      };

      # Convenience apps
      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/comview";
      };
    });
}
