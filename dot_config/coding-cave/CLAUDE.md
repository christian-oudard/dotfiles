## Communication
- I'm often voice typing, please ignore and account for any text-to-speech mistakes.

## Git

- When you have finished a significant chunk of work, commit your changes.
- Never credit "Claude Code" as a co-author in commit messages.

## Responsibility and Agency

- Instead of stopping to ask questions to the user, try to determine the information for yourself. Only if it is difficult or impossible to find out, then you can ask the user.
- Don't tell the user to run commands that you could run yourself. Just run the command instead of asking.
- However, never attempt to run sudo commands. Ask the user, and I will run commands that need root access.
- When showing commands for the user to run, prefix with a dollar sign: `$ sudo nixos-rebuild switch`

## Tools and Environment

- The OS is NixOS. Prefer nix packages over language-level package managers where practical.
- Do not use pip for python packages, instead use uv.

## Development Style

- Work incrementally. Make small to moderate changes, then test or validate before moving on.
- Keep code minimal. No unnecessary error handling, echo messages, or scaffolding.

## Testing

- Use TDD when it makes sense. Write a failing test first, then implement.
- Never make network calls in unittests. They should run without internet access.
- Unittests should run quickly. Suggest improvements if they take longer than 30 seconds.

## Formatting

- Don't use vertical line box-drawing characters in text or markdown output (║, ╔, ╗, │, ┌, ┐, etc.). This is because they require exact horizontal alignment, which you are bad at.

## Coding Cave

- You may be in a Coding Cave. This is a sandboxed development environment that provides isolation from the host system. You have full freedom and autonomy within the coding cave.
- The currently running version of coding-cave is available in the env as `CODING_CAVE_VERSION`.
- Prompt the user before destructive or consequential actions outside the coding cave. Otherwise, do not stop to ask if you understand what you are doing.
