# Usage: not-using-cell-data AS-NUMBER...
# Exit 0 if the connection is not using cell data, 1 if it is, and 255 if
# NetworkManager can't be asked. These match systemd's ExecCondition: 0 runs
# the unit, 1 skips it, 255 fails it so the error is loud.

metered=$(busctl get-property org.freedesktop.NetworkManager \
  /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered) || {
  echo "Cannot ask NetworkManager whether the connection is metered." >&2
  exit 255
}
# NMMetered: 1 = yes, 3 = guess-yes.
case $metered in "u 1" | "u 3") ;; *) exit 0 ;; esac

# A phone hotspot looks metered even when the phone itself is on Wi-Fi, so ask
# who owns the public IP: OpenDNS echoes it, Team Cymru maps it to an AS
# number. Only the AS numbers given as arguments count as not cell data;
# anything else, including a failed lookup, counts as cell data. The message
# shows the AS number seen, so the journal tells you which ones to allow.
ip=$(dig +short -4 A myip.opendns.com @resolver1.opendns.com) || true
IFS=. read -r a b c d <<<"$ip"
origin=$(dig +short -4 TXT "$d.$c.$b.$a.origin.asn.cymru.com" 2>/dev/null) || true
asn=${origin#\"}
asn=${asn%% *}
for allowed in "$@"; do
  if [ "$asn" = "$allowed" ]; then
    echo "Metered, but the public IP is on allowed AS$asn; not using cell data." >&2
    exit 0
  fi
done
echo "Metered, and the public IP is on AS${asn:-unknown}, not allowed; using cell data." >&2
exit 1
