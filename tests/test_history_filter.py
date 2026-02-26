"""Tests for zsh history filter.

The history filter is a zshaddhistory hook that prevents dangerous commands
from being saved to shell history. Return 0 = save, return 1 = suppress.

Test harness: sources the zsh file and calls the hook function via subprocess.
"""

import shlex
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
# During development, the filter lives next to the tests. It will be moved to
# dot_config/zsh/history_filter.zsh for deployment via chezmoi.
FILTER_PATH = Path(__file__).resolve().parent / "history_filter.zsh"


def is_saved(cmd: str) -> bool:
    """Returns True if the command would be saved to history."""
    # zshaddhistory receives command with trailing newline
    result = subprocess.run(
        [
            "zsh",
            "-c",
            f"source {FILTER_PATH}; zshaddhistory {shlex.quote(cmd + chr(10))}",
        ],
        capture_output=True,
        cwd=str(REPO),
    )
    return result.returncode == 0


# --- Safe commands: always saved ---


def test_ls():
    assert is_saved("ls -la")


def test_cd():
    assert is_saved("cd /tmp")


def test_git_status():
    assert is_saved("git status")


def test_vim():
    assert is_saved("vim foo.txt")


def test_echo():
    assert is_saved("echo hello world")


def test_grep():
    assert is_saved("grep -r pattern .")


def test_empty():
    assert is_saved("")


def test_cat():
    assert is_saved("cat /etc/hosts")


# --- Always dangerous commands ---


def test_mkfs():
    assert not is_saved("mkfs /dev/sda1")


def test_mkfs_ext4():
    assert not is_saved("mkfs.ext4 /dev/sda1")


def test_mkfs_btrfs():
    assert not is_saved("mkfs.btrfs /dev/sda1")


def test_mke2fs():
    assert not is_saved("mke2fs /dev/sda1")


def test_shred():
    assert not is_saved("shred /dev/sda")


def test_wipefs():
    assert not is_saved("wipefs -a /dev/sda")


def test_dd():
    assert not is_saved("dd if=/dev/zero of=/dev/sda")


def test_reboot():
    assert not is_saved("reboot")


def test_shutdown():
    assert not is_saved("shutdown -h now")


def test_poweroff():
    assert not is_saved("poweroff")


def test_halt():
    assert not is_saved("halt")


# --- Prefix stripping ---


def test_sudo_dangerous():
    assert not is_saved("sudo mkfs /dev/sda1")


def test_command_dangerous():
    assert not is_saved("command shred /dev/sda")


def test_nohup_dangerous():
    assert not is_saved("nohup dd if=/dev/zero of=/dev/sda")


def test_env_dangerous():
    assert not is_saved("env mkfs.ext4 /dev/sda1")


def test_sudo_env_dangerous():
    assert not is_saved("sudo env dd if=/dev/zero of=/dev/sda")


def test_nice_dangerous():
    assert not is_saved("nice shred /dev/sda")


def test_sudo_safe():
    assert is_saved("sudo apt update")


def test_command_safe():
    assert is_saved("command ls -la")


# --- rm ---
# Safe: no -r, no -f, named targets only


def test_rm_named_file():
    assert is_saved("rm foo.txt")


def test_rm_multiple_named():
    assert is_saved("rm foo.txt bar.txt")


def test_rm_interactive():
    assert is_saved("rm -i foo.txt")


def test_rm_verbose():
    assert is_saved("rm -v foo.txt")


def test_rm_path():
    assert is_saved("rm /tmp/foo.txt")


def test_rm_rf_slash():
    assert not is_saved("rm -rf /")


def test_rm_rf_star():
    assert not is_saved("rm -rf *")


def test_rm_r_f_separate():
    assert not is_saved("rm -r -f /home")


def test_rm_recursive_force_long():
    assert not is_saved("rm --recursive --force /")


def test_rm_rf_home():
    assert not is_saved("rm -rf ~/")


def test_rm_f():
    assert not is_saved("rm -f foo.txt")


def test_rm_r():
    assert not is_saved("rm -r somedir")


def test_rm_R():
    assert not is_saved("rm -R somedir")


def test_rm_recursive_long():
    assert not is_saved("rm --recursive somedir")


def test_rm_force_long():
    assert not is_saved("rm --force foo.txt")


def test_rm_star():
    assert not is_saved("rm *")


def test_rm_glob():
    assert not is_saved("rm *.log")


def test_rm_question_glob():
    assert not is_saved("rm file?.txt")


def test_sudo_rm_rf():
    assert not is_saved("sudo rm -rf /")


def test_rm_piped():
    """Piping into rm -rf should be caught."""
    assert not is_saved("find . -name '*.tmp' | xargs rm -rf")


def test_rm_piped_sudo():
    assert not is_saved("cat files.txt | sudo rm -rf")


def test_rm_rf_in_pipeline():
    """rm -rf anywhere in a pipeline should be caught."""
    assert not is_saved("ls | rm -rf")


# --- Command separators (;, &&, ||) ---


def test_dangerous_after_semicolon():
    assert not is_saved("ls; rm -rf /")


def test_dangerous_after_and():
    assert not is_saved("ls && rm -rf /")


def test_dangerous_after_or():
    assert not is_saved("ls || rm -rf /")


def test_dangerous_after_and_with_sudo():
    assert not is_saved("echo foo && sudo mkfs /dev/sda")


def test_safe_semicolon():
    assert is_saved("cd /tmp; ls")


# --- chmod / chown ---


def test_chmod_safe():
    assert is_saved("chmod 644 foo.txt")


def test_chmod_R_slash():
    assert not is_saved("chmod -R 777 /")


def test_chmod_recursive_long():
    assert not is_saved("chmod --recursive 777 /")


def test_chmod_R_star():
    assert not is_saved("chmod -R 777 *")


def test_chown_safe():
    assert is_saved("chown user:group foo.txt")


def test_chown_R_slash():
    assert not is_saved("chown -R root:root /")


def test_chown_R_star():
    assert not is_saved("chown -R user:group *")


def test_sudo_chmod_R():
    assert not is_saved("sudo chmod -R 777 /")


def test_chmod_R_specific_dir():
    """chmod -R on a specific directory is routine and safe."""
    assert is_saved("chmod -R 755 src/")


def test_chown_R_specific_dir():
    assert is_saved("chown -R user:group /home/user/project")


# --- git ---


def test_git_push_force():
    assert not is_saved("git push --force")


def test_git_push_f():
    assert not is_saved("git push -f")


def test_git_push_force_with_lease():
    """force-with-lease is safer but still dangerous enough to exclude."""
    assert not is_saved("git push --force-with-lease")


def test_git_reset_hard():
    assert not is_saved("git reset --hard")


def test_git_reset_hard_ref():
    assert not is_saved("git reset --hard HEAD~3")


def test_git_clean_f():
    assert not is_saved("git clean -f")


def test_git_clean_fdx():
    assert not is_saved("git clean -fdx")


def test_git_clean_dry_run():
    """Dry-run is the safe version — repeat the dry-run, not the destructive one."""
    assert is_saved("git clean -n")


def test_git_clean_dry_run_long():
    assert is_saved("git clean --dry-run")


def test_git_push_safe():
    assert is_saved("git push")


def test_git_push_origin():
    assert is_saved("git push origin main")


def test_git_reset_soft():
    assert is_saved("git reset --soft HEAD~1")


def test_git_commit():
    assert is_saved("git commit -m 'message'")


# --- kill ---


def test_kill_all_processes():
    assert not is_saved("kill -9 -1")


def test_kill_specific():
    assert is_saved("kill 1234")


def test_kill_signal_specific():
    assert is_saved("kill -9 1234")


def test_kill_term():
    assert is_saved("kill -TERM 5678")


# --- iptables ---


def test_iptables_flush():
    assert not is_saved("iptables -F")


def test_iptables_flush_long():
    assert not is_saved("iptables --flush")


def test_sudo_iptables_flush():
    assert not is_saved("sudo iptables -F")


def test_iptables_safe():
    assert is_saved("iptables -L")


# --- Secrets ---


def test_secret_openai_key():
    assert not is_saved(
        'curl -H "Authorization: Bearer sk-proj-abc123def456ghi789jkl012mno"'
    )


def test_secret_github_pat():
    assert not is_saved("export TOKEN=ghp_ABCDEFghijklmnopqrstuv1234567890")


def test_secret_github_oauth():
    assert not is_saved("export TOKEN=gho_ABCDEFghijklmnopqrstuv1234567890")


def test_secret_aws_key():
    assert not is_saved("export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE")


def test_secret_password_flag():
    """--password= is unambiguous — always means a secret."""
    assert not is_saved("some-cmd --password=secret123")


def test_mysql_p_not_blocked():
    """-p'val' is ambiguous (less -p'pattern', grep -P, etc). Don't block."""
    assert is_saved("mysql -p'mypassword' mydb")


def test_secret_not_short_match():
    """Short strings matching prefixes should not be blocked."""
    assert is_saved("grep ghp_ config.py")


def test_secret_not_prefix_in_word():
    """Token prefix as part of a normal word should not be blocked."""
    assert is_saved("echo something")
