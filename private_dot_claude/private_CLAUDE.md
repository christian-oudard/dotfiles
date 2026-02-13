# Development Style

- Work incrementally. Make small to moderate changes, then test or validate before moving on.
- Keep code minimal. No unnecessary error handling, echo messages, or scaffolding.
- Prompt the user before destructive or consequential actions (deleting data, overwriting files, modifying system config).
- Do not attempt to read secrets or system configuration without asking first.

# Testing

- Use TDD when it makes sense. Write a failing test first, then implement.
- Never make network calls in unittests. They should run without internet access.
- Unittests should run quickly. Suggest improvements if they take longer than 30 seconds.

# Tools and Environment

- OS is NixOS. Prefer nix packages over language-level package managers where practical.
- Prefer uv over pip for Python package management.
- Never run sudo commands. Ask me, and I will run commands that need root access.
- When showing commands for me to run, prefix with a dollar sign: `$ sudo nixos-rebuild switch`

# Formatting

- Don't use box-drawing characters (║, ╔, ╗, │, ┌, ┐, etc.) that require exact horizontal alignment. Use `====` or `----` dividers instead.

# Git

- Don't credit "Claude Code" as a co-author in commit messages.
