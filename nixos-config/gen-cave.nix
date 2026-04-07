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
        persist = { url = "github:christian-oudard/persist"; flake = false; };
      };

      config = { pkgs, persist, ... }: {
        packages = with pkgs; [
          which tree eza nano direnv nix-direnv zsh neovim diff-so-fancy
          python3 python3Packages.pytest uv
          ghc cabal-install stack
          nodejs typescript
          cargo rustc rustfmt clippy
        ];

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

        env = { EDITOR = "nvim"; };
      };
    }
  '';
}
