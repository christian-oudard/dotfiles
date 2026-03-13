## Communication

- I'm often voice typing, please ignore and account for any text-to-speech mistakes.
- When showing commands for the user to run, prefix with a dollar sign: `$ sudo nixos-rebuild switch`

## Git

- When you have finished a significant chunk of work, commit your changes.
- Never credit "Claude Code" as a co-author in commit messages.
- Don't make multiple commits in a row touching the same file. Amend instead.
- Only amend commits after origin/main. Do not amend pushed commits.

## Responsibility and Agency

- Instead of stopping to ask questions to the user, try to determine the information for yourself. Only if it is difficult or impossible to find out, then you can ask the user.
- Don't tell the user to run commands that you could run yourself. Just run the command instead of asking.
- Never use EnterPlanMode. It requires user approval to exit, trapping you until the user intervenes. Use TaskCreate/TaskList/TaskUpdate for tracking multi-step work instead.
- Be humble. If you don't know something, just ask the question and pass that question along, to be clarified later. Don't guess or assume if you don't *know*.

## Tools and Environment

- Prefer nix packages over language-level package managers where practical.
- Do not use pip for python packages, instead use uv.

## Development Style

- Work incrementally. Make small to moderate changes, then test or validate before moving on.
- Keep code minimal. No unnecessary error handling, echo messages, or scaffolding.
- Periodically look for opportunities to simplify — remove unnecessary abstractions, reduce indirection, and consolidate code that has grown more complex than the problem requires.
- Before you decide that something is done, do a code review and see if there's anything else you missed.
- Fail Loudly. If there is a chance of something failing, let it fail, do not suppress crucial errors.
- Don't Repeat Yourself (DRY). If you are doing the same thing multiple times, refactor it into something repeatable.
- You Ain't Gonna Need It (YAGNI). Only build what is required now, do not overbuild by speculating what will be required in the future.

## Testing

- Use Test-Driven Development (TDD) when it makes sense to. First, the specification (SPEC.md) reflects current thinking. Then, the unittests match the spec, and fail (red). Then lastly, the code passes the unittests (green)
- Never make network calls in unittests. They should run without internet access.
- Unittests should run quickly. Optimize the test procedure, or separate slow tests if they take longer than 30 seconds.

## Formatting

- Don't use vertical line box-drawing characters in text or markdown output. This is because they require exact horizontal alignment, which you are bad at.
