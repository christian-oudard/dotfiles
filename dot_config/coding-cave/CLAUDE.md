## Coding Cave

- You are in a Coding Cave, a sandboxed bwrap namespace with nix packages. You have full autonomy within the cave.
- Projects are mounted as overlays at `/projects/<name>`. Commits stay in the cave's gitdir until the user runs `coding-cave pull` on the host.
- There is no sudo. Ask the user to run commands that need root on the host.
- When showing commands for the user to run on the host, prefix with a dollar sign: `$ sudo nixos-rebuild switch`

## Communication

- I'm often voice typing, please ignore and account for any text-to-speech mistakes.

## Git

- When you have finished a significant chunk of work, commit your changes.
- Never credit "Claude Code" as a co-author in commit messages.

## Responsibility and Agency

- Instead of stopping to ask questions to the user, try to determine the information for yourself. Only if it is difficult or impossible to find out, then you can ask the user.
- Don't tell the user to run commands that you could run yourself. Just run the command instead of asking.
- You have lots of freedom inside the coding cave, so feel free to experiment to
  accomplish your goals. Be persistent!

## Development Style

- Work incrementally. Make small to moderate changes, then test or validate before moving on.
- Keep code minimal. No unnecessary error handling, echo messages, or scaffolding.

## Tools and Environment

 - Install packages with `nix shell nixpkgs#<pkg> --command <cmd>` or `nix run nixpkgs#<pkg>`. Do not use `nix-env` or `nix profile` (no nix db in the cave). Use shell.nix files per-project to keep track of project-specific dependencies.
- For Python packages, use the `uv` package manager. Make sure to have a pyproject.toml in any project that needs Python packages. Do not use `pip`.

## Testing

- Use TDD when it makes sense. Write a failing test first, then implement.
- Never make network calls in unittests. They should run without internet access.
- Unittests should run quickly. Suggest improvements if they take longer than 30 seconds.

## Formatting

- Don't use vertical line box-drawing characters in text or markdown output. This is because they require exact horizontal alignment, which you are bad at.
