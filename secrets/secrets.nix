# This file defines which keys can decrypt which secrets.
# Only public keys go here - this file is safe to commit.
let
  # Personal age key (from ~/.keys/age_chezmoi_key.txt)
  christian = "age1apnl93pm2smqnd5pkh04suhj3h9a73wtg05p3mtugzw75y8jyg3scfser2";
in {
  # Git config (signing key, credentials)
  "git-config.age".publicKeys = [ christian ];

  # Modal CLI config
  "modal.toml.age".publicKeys = [ christian ];

  # Ngrok config
  "ngrok.yml.age".publicKeys = [ christian ];

  # Shell environment secrets (API keys, tokens, etc.)
  "zshrc-private.age".publicKeys = [ christian ];
}
