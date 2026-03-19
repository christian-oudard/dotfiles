# history_filter.zsh — zshaddhistory hook to filter history entries.
# Source this file from zshrc.
#
# Two mechanisms:
# 1. Pre-execution: zshaddhistory blocks dangerous commands (return 1)
#    and defers safe commands (return 2 = session-only, not written to file).
# 2. Post-execution: precmd hook persists deferred commands only if they
#    succeeded (exit code 0). Failed commands stay in the current session
#    for arrow-up but are never written to HISTFILE.

zmodload zsh/datetime  # provides $EPOCHSECONDS

# --- Layer 2: Always dangerous commands ---
typeset -gA _hf_always_dangerous
_hf_always_dangerous=(
  mkfs 1 mke2fs 1 shred 1 wipefs 1 dd 1
  reboot 1 shutdown 1 poweroff 1 halt 1
)

# --- Layer 1: Strip transparent prefixes ---
# Removes sudo, command, nohup, env, nice, backslash escapes from the front
# of a command, returning the remaining words via $reply array.
_hf_strip_prefix() {
  local -a words
  words=("${(z)1}")
  while (( ${#words} > 0 )); do
    case ${words[1]} in
      sudo|command|nohup|nice|xargs|\\*) words=("${words[@]:1}") ;;
      env)
        # env may have VAR=val args before the command
        words=("${words[@]:1}")
        while (( ${#words} > 0 )) && [[ ${words[1]} == *=* ]]; do
          words=("${words[@]:1}")
        done
        ;;
      *) break ;;
    esac
  done
  reply=("${words[@]}")
}

# --- Layer 3: Conditional checkers ---
# Each returns 0 if dangerous, 1 if safe.

_hf_check_rm() {
  local -a words
  words=("$@")
  shift  # remove "rm"
  words=("$@")

  local has_r=0 has_f=0 has_glob=0
  for w in "${words[@]}"; do
    case $w in
      --)           break ;;
      --recursive)  has_r=1 ;;
      --force)      has_f=1 ;;
      -*)
        # Check each char in collapsed flags like -rf, -rfi, etc.
        local flags="${w#-}"
        [[ $flags == *r* || $flags == *R* ]] && has_r=1
        [[ $flags == *f* ]] && has_f=1
        ;;
      *)
        # Check for glob characters in targets
        [[ $w == *'*'* || $w == *'?'* || $w == *'['* ]] && has_glob=1
        ;;
    esac
  done

  # Dangerous if any of: -r, -f, or glob targets
  (( has_r || has_f || has_glob )) && return 0
  return 1
}

_hf_check_chmod_chown() {
  local has_R=0
  local has_broad_target=0
  shift  # remove chmod/chown
  for w in "$@"; do
    case $w in
      --recursive) has_R=1 ;;
      -*)
        local flags="${w#-}"
        [[ $flags == *R* ]] && has_R=1
        ;;
      *)
        # Literal match for broad targets — case patterns can't do this
        # because * is always a glob in case, even when quoted.
        if [[ "$w" == "/" || "$w" == "~" || "$w" == "~/" || "$w" == "*" ]]; then
          has_broad_target=1
        fi
        ;;
    esac
  done
  (( has_R && has_broad_target )) && return 0
  return 1
}

_hf_check_git() {
  shift  # remove "git"
  local subcmd="${1:-}"
  shift 2>/dev/null
  case $subcmd in
    push)
      for w in "$@"; do
        case $w in
          -f|--force|--force-with-lease) return 0 ;;
        esac
      done
      ;;
    reset)
      for w in "$@"; do
        [[ $w == "--hard" ]] && return 0
      done
      ;;
    clean)
      for w in "$@"; do
        case $w in
          -*)
            local flags="${w#-}"
            [[ $flags == *f* ]] && return 0
            ;;
        esac
      done
      ;;
  esac
  return 1
}

_hf_check_kill() {
  # Only block "kill -9 -1" (kill all processes)
  local -a words
  words=("$@")
  # Look for -1 as a target (meaning all processes)
  local i
  for (( i=2; i<=${#words}; i++ )); do
    [[ ${words[$i]} == "-1" ]] && return 0
  done
  return 1
}

_hf_check_iptables() {
  shift  # remove iptables/ip6tables
  for w in "$@"; do
    case $w in
      -F|--flush) return 0 ;;
    esac
  done
  return 1
}

# --- Layer 4: Secret detection ---
_hf_has_secrets() {
  local cmd="$1"
  # Token patterns: prefix + at least 20 alphanumeric chars
  [[ $cmd =~ sk-[a-zA-Z0-9_-]{20,} ]] && return 0
  [[ $cmd =~ ghp_[a-zA-Z0-9]{20,} ]] && return 0
  [[ $cmd =~ gho_[a-zA-Z0-9]{20,} ]] && return 0
  [[ $cmd =~ ghs_[a-zA-Z0-9]{20,} ]] && return 0
  [[ $cmd =~ AKIA[A-Z0-9]{12,} ]] && return 0
  # --password= is unambiguous enough to block
  [[ $cmd =~ --password= ]] && return 0
  return 1
}

# --- Check a single command segment (no pipes) ---
_hf_check_segment() {
  local -a words
  words=("${(z)1}")
  (( ${#words} == 0 )) && return 1

  # Strip prefixes
  local -a reply
  _hf_strip_prefix "$1"
  words=("${reply[@]}")
  (( ${#words} == 0 )) && return 1

  local cmd="${words[1]}"

  # Layer 2: always dangerous (also match mkfs.*)
  [[ -n "${_hf_always_dangerous[$cmd]}" ]] && return 0
  [[ $cmd == mkfs.* ]] && return 0

  # Layer 3: conditional checks
  case $cmd in
    rm)     _hf_check_rm "${words[@]}" && return 0 ;;
    chmod|chown) _hf_check_chmod_chown "${words[@]}" && return 0 ;;
    git)    _hf_check_git "${words[@]}" && return 0 ;;
    kill)   _hf_check_kill "${words[@]}" && return 0 ;;
    iptables|ip6tables) _hf_check_iptables "${words[@]}" && return 0 ;;
  esac

  return 1
}

# --- Main hook ---
zshaddhistory() {
  local cmd="${1%%$'\n'}"
  [[ -z "$cmd" ]] && return 0

  # Honour histignorespace: leading space keeps in session, skips HISTFILE.
  [[ "$cmd" == [[:space:]]* ]] && return 2

  # Layer 4: secrets (check full line before splitting)
  _hf_has_secrets "$cmd" && return 1

  # Split on pipes, semicolons, && and || then check each segment.
  # Must disable extended_glob because | is a glob operator in patterns.
  # $'\x01' must be in a variable — it's not interpreted in ${//} replacements.
  setopt local_options no_extended_glob
  local sep=$'\x01'
  local normalized="${cmd//&&/${sep}}"
  normalized="${normalized//||/${sep}}"
  normalized="${normalized//;/${sep}}"
  normalized="${normalized//|/${sep}}"
  local segment
  local IFS="$sep"
  for segment in ${=normalized}; do
    _hf_check_segment "$segment" && return 1
  done

  # Command passed all filters. Defer to precmd — persist only on success.
  __hf_pending="$cmd"
  __hf_pending_time=$EPOCHSECONDS
  return 2  # add to session history, don't write to file yet
}

# --- Persist successful commands, discard failed ones ---
__hf_persist_or_discard() {
  local last_status=$?
  if [[ -n "$__hf_pending" ]] && (( last_status == 0 )); then
    local elapsed=$(( EPOCHSECONDS - __hf_pending_time ))
    print -r -- ": ${__hf_pending_time}:${elapsed};${__hf_pending}" >> "$HISTFILE"
  fi
  __hf_pending=""
  return $last_status
}
# Must be first in precmd_functions to capture $? before other hooks change it.
precmd_functions=(__hf_persist_or_discard "${precmd_functions[@]}")

# Prevent zsh from writing deferred (failed) commands to HISTFILE on exit.
# Successful commands were already appended in precmd.
zshexit() { unset HISTFILE; }
