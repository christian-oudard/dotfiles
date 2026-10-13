# Trash

In zsh, `tp` moves files to the trash. It takes rm's flags: `-r` for directories, `-f` to ignore missing files, `-i` and `-I` to prompt, and `-d` for empty directories.

`rm` refuses to run and points to `tp`. Use `command rm` to delete for real. Claude Code agents are denied `rm` and `command rm`, and use `gtrash put --rm-mode` instead. `mv` and `cp` ask before overwriting a file. If you confirm, the old file is kept beside the new one as `name.~1~`, `name.~2~`, and so on. Scripts are not affected.

Files from the root filesystem go to `~/.local/share/Trash`. Files from other filesystems, such as a USB drive, go to a `.Trash-1000` folder at the root of that drive.

`gtrash restore` picks files to restore in a fuzzy-search screen. `gtrash find` lists and filters the trash.

Trashed files are kept for 30 days, then deleted for good. This applies to every trash folder, including those on other drives. The trash is not backed up.
