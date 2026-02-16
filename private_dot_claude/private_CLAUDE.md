## Responsibility and Agency
- Instead of stopping to ask questions to the user, try to determine the information for yourself. Only if it is difficult or impossible to find out, then you can ask the user.
- Don't tell the user to run commands that you could run yourself. Just run the command instead of asking.
- However, never attempt to run sudo commands. Ask the user, and I will run commands that need root access.
- When showing commands for the user to run, prefix with a dollar sign: `$ sudo nixos-rebuild switch`

## Tools and Environment

- OS is NixOS. Prefer nix packages over language-level package managers where practical.
- Prefer uv over pip for Python package management.

## Development Style

- Work incrementally. Make small to moderate changes, then test or validate before moving on.
- Keep code minimal. No unnecessary error handling, echo messages, or scaffolding.
- Prompt the user before destructive or consequential actions (deleting data, overwriting files, modifying system config).
- Do not attempt to read secrets or system configuration without asking first.

## Testing

- Use TDD when it makes sense. Write a failing test first, then implement.
- Never make network calls in unittests. They should run without internet access.
- Unittests should run quickly. Suggest improvements if they take longer than 30 seconds.

## Formatting

- Don't use box-drawing characters (║, ╔, ╗, │, ┌, ┐, etc.) that require exact horizontal alignment. Use `====` or `----` dividers instead.

## Git

- Don't credit "Claude Code" as a co-author in commit messages.
