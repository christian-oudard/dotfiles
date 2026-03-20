{
  persist,
  claude-plugins-official,
  agent-capabilities,
}:

let
  claude = import ./claude.nix { inherit persist claude-plugins-official agent-capabilities; };
in
{ pkgs, lib, ... }:

{
  xdg.configFile."coding-cave/cave.nix".text = ''
    {
      inputs = {
        persist = "github:christian-oudard/persist";
      };

      config = { pkgs, persist, ... }: {
        claude = {
          plugins = [
            persist
    ${lib.concatMapStringsSep "\n" (src: "        { src = \"${src}\"; }") (
      lib.attrValues claude.pluginSources
    )}
          ];
          settings = ${
            builtins.replaceStrings [ "\n" ] [ "\n      " ] (lib.generators.toPretty { } claude.settings)
          };
        };

        files = {
          ".config/direnv/direnvrc" = "source ''${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
        };

        packages = with pkgs; [
          # General
          tree eza nano direnv nix-direnv zsh neovim diff-so-fancy
          # Python
          python3 python3Packages.pytest uv
          # Haskell
          ghc cabal-install stack
          # JS/TypeScript
          nodejs typescript
          # Rust
          cargo rustc rustfmt clippy
        ];

        env = {
          EDITOR = "nvim";
        };
      };
    }
  '';
}
