#!/bin/sh
# Trust the sandbox proxy CA in Chromium's NSS database (Chromium ignores SSL_CERT_FILE).
# The workload entrypoint writes proxy-ca.crt before running hooks.
set -e

crt="$HOME/.local/share/ca-certificates/proxy-ca.crt"
[ -f "$crt" ] || exit 0

if ! command -v certutil >/dev/null 2>&1; then
  echo "chromium-ca: certutil not found; Chromium will not trust the sandbox proxy CA" >&2
  exit 1
fi

nss_db="$HOME/.pki/nssdb"
mkdir -p "$nss_db"
[ -f "$nss_db/cert9.db" ] || certutil -d "sql:$nss_db" -N --empty-password
certutil -d "sql:$nss_db" -A -t "C,," -n sandbox-proxy -i "$crt"
