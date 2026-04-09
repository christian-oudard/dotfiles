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
        home.packages = with pkgs; [
          which tree eza nano direnv nix-direnv zsh neovim
          python3 python3Packages.pytest uv
          ghc cabal-install stack
          nodejs typescript
          cargo rustc rustfmt clippy
          chromium
        ];

        coding-cave.claude-code = {
          plugins = [
            (import persist { inherit pkgs; })
    ${lib.concatMapStringsSep "\n" (src: "        \"${src}\"") claude.pluginPaths}
          ];
          extraSettings = ${
            builtins.replaceStrings [ "\n" ] [ "\n          " ] (lib.generators.toPretty { } claude.settings)
          };
        };

        home.file.".config/direnv/direnvrc".text =
          "source ''${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

        home.sessionVariables = {
          EDITOR = "nvim";
          PERSIST_BELL_CMD = "printf '\\a' > /proc/$PPID/fd/1";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
          CHROMIUM_PATH = "''${pkgs.chromium}/bin/chromium";
        };
      };
    }
  '';
}
