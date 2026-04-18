## Communication

- I'm often voice typing, please ignore and account for any text-to-speech mistakes.
- When showing commands for the user to run, prefix with a dollar sign, e.g. `$ sudo nixos-rebuild switch`. Use the `\` shell operator to wrap long shell inputs to less than 80 characters, to preserve copy-paste ability.

## Git

- When you have finished a significant chunk of work, commit your changes.
- Don't make multiple commits in a row doing the same thing. Instead, amend.
- Only amend commits that have not been pushed. Do not amend commits that have been shared with others.
- Never credit "Claude Code" as a co-author in commit messages.
- Commit subject describes the user-visible change, not the mechanism. Body describes what changed in the code. Use imperative mood.

Bad subject: "Set max-old-space-size to 4096 in Node startup script"
Good: "Fix out-of-memory crashes during large CSV exports"
Body: "Increase Node heap limit to 4096MB in startup script"

## Responsibility and Agency

- Instead of stopping to ask questions to the user, try to determine the information for yourself.
- Don't tell the user to run commands that you could run yourself. Just run the command instead of asking.
- Never use EnterPlanMode. It requires user approval to exit, trapping you until the user intervenes. Use TaskCreate/TaskList/TaskUpdate for tracking multi-step work instead.
- Be humble! If you don't know something, just ask the question and pass that question along, to be clarified later. Don't guess or assume if you don't *know*.
- Be pessimistic! Assume that things will not work, and that we're missing something, and that we are confused, until proven otherwise by testing.
- Be persistent! Keep trying new things, or variants of old things. Success is often possible.

## Tools and Environment

- Prefer Nix packages over language-level package managers where practical.
- Do not use `pip` for Python packages, instead use `uv`. Do not use npm, u

## Development Style

- Maintain a specification document (SPEC.md) that says *what* the software does, but not *how* it is built. No implementation details in SPEC.md.
- Work incrementally. Make small to moderate changes, then test or validate before moving on.
- Keep code minimal. No unnecessary error handling, echo messages, or scaffolding.
- Periodically look for opportunities to simplify. Improve on poor organization and inconsistencies, add useful abstractions, reduce indirection, and consolidate code that has grown more complex than the problem requires.
- Fail Loudly. Do not catch exceptions unless really necessary. Let it fail, do not suppress crucial errors. Do not keep backward compatibility unless asked to. Do not fallback, or work-around.
- Don't Repeat Yourself (DRY). If you are doing the same thing multiple times, refactor it into something repeatable.
- You Ain't Gonna Need It (YAGNI). Only build what is required now, do not overbuild by speculating what will be required in the future.

## Research Before Code

Before writing code, search for existing solutions. Applications usually have a config option for what you need. WebSearch for the app's config format and the specific problem. Prefer config changes over env vars over wrapper scripts over patches.

## Testing

- Use Test-Driven Development (TDD) as a methodology. First, SPEC.md reflects current design. Secondly, unittests reflect the spec, and fail (red). Finally, the code passes the unittests (green).
- Never make network calls in unittests. They should run without internet access.
- Unittests should run quickly. Optimize the test procedure, or separate slow tests if they take longer than 30 seconds.
- Any time you notice that you or the code have made a mistake or gotten confused, that is a good opportunity to learn and write a unittest.

## Formatting

- Don't use vertical line box-drawing characters in text or markdown output. This is because they require exact horizontal alignment, which you are bad at.
- Systematically replace em-dashes ("—") with a period (".") to start a new sentence, or a comma (",") to continue the sentence.
