#!/usr/bin/env bash
# S1 · Proves the edge delivery stack is working as described in README.md.
# Read-only. Safe to run against a live distribution.
set -uo pipefail

HOST="cedar.banik.dev"
BUCKET_ENDPOINT="cedar-clinic-site-7412.s3.us-west-2.amazonaws.com"
PAGES=(index.html services.html contact.html styles.css logo.svg)

echo "== DNS =="
dig +short A "$HOST" | head -4

echo
echo "== HTTPS and redirect =="
curl -s -o /dev/null -w "https  %{http_code}  tls_verify=%{ssl_verify_result}  ttfb=%{time_starttransfer}\n" "https://$HOST/"
curl -s -o /dev/null -w "http   %{http_code}  -> %{redirect_url}\n" "http://$HOST/"

echo
echo "== Origin is private =="
curl -s -o /dev/null -w "s3 direct  %{http_code}  (expect 403)\n" "https://$BUCKET_ENDPOINT/index.html"

echo
echo "== Cache hit ratio across all objects =="
for p in "${PAGES[@]}"; do
  curl -s -o /dev/null -D - "https://$HOST/$p" | grep -i '^x-cache:' | tr -d '\r'
done | sort | uniq -c

echo
echo "== TTFB, cached against cache-disabled =="
for _ in 1 2 3 4 5; do
  curl -s -o /dev/null -w "cached %{time_starttransfer}  " "https://$HOST/index.html"
  curl -s -o /dev/null -w "nocache %{time_starttransfer}\n" "https://$HOST/nocache/index.html"
done
echo "(discard the first row: connection setup, not cache)"

echo
echo "== Same bytes on both paths =="
curl -sI "https://$HOST/index.html"         | grep -iE '^(x-cache|content-length|content-encoding):' | tr -d '\r'
curl -sI "https://$HOST/nocache/index.html" | grep -iE '^(x-cache|content-length|content-encoding):' | tr -d '\r'
