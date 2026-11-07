#!/bin/sh
# Read-only validation of external APK feeds for OpenWrt 25.12.6 x86/legacy.
# Runs inside an ephemeral Alpine 3.24 container (apk-tools 3.x).
set -eu

REL="25.12"
OPENWRT_RELEASE="25.12.6"
ARCH="x86_64"
SOC="legacy"
LAN132_ROOT="https://openwrt.132lan.ru/packages"
LAN132_ARCH="${LAN132_ROOT}/${REL}/packages/${ARCH}"
LAN132_MODEM="${LAN132_ARCH}/modemfeed"
LAN132_KMOD="${LAN132_ARCH}/kmods/${OPENWRT_RELEASE}/${SOC}"
LAN132_KEY="${LAN132_ROOT}/${REL}/packages/repo.pem"
ICEG_ROOT="https://raw.githubusercontent.com/4IceG/Modem-extras-apk/main/myapk"
ICEG_ADB="${ICEG_ROOT}/packages.adb"
ICEG_KEY="${ICEG_ROOT}/IceG-apkpub.pem"

apk add --no-cache curl jq openssl

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
KEYS="$WORK/keys"
REPOS="$WORK/repositories"
mkdir -p "$KEYS"

fetch_key() {
    url="$1"
    dest="$2"
    curl --fail --silent --show-error --location "$url" --output "$dest"
    test -s "$dest"
    openssl pkey -pubin -in "$dest" -noout
}

echo "== Fetch and validate signing keys =="
fetch_key "$LAN132_KEY" "$KEYS/132lan-repo.pem"
fetch_key "$ICEG_KEY" "$KEYS/IceG-apkpub.pem"

echo "== Check feed metadata and signed index endpoints =="
for url in "${LAN132_MODEM}/index.json" "${LAN132_KMOD}/index.json"; do
    curl --fail --silent --show-error --location "$url" --output "$WORK/index.json"
    jq -e . "$WORK/index.json" >/dev/null
    echo "metadata OK: $url"
done
curl --fail --silent --show-error --location "${ICEG_ROOT}/index.json" --output "$WORK/iceg-index.json"
jq -e . "$WORK/iceg-index.json" >/dev/null
echo "metadata OK: ${ICEG_ROOT}/index.json"

cat > "$REPOS" <<EOF
${LAN132_MODEM}/packages.adb
${LAN132_KMOD}/packages.adb
${ICEG_ADB}
EOF

echo "== Verify repository index signatures with apk-tools 3.x =="
apk --version
apk --keys-dir "$KEYS" --repositories-file "$REPOS" --cache-dir "$WORK/cache" --force-refresh update

echo "== Check required package records =="
require_package() {
    name="$1"
    if ! apk --keys-dir "$KEYS" --repositories-file "$REPOS" --cache-dir "$WORK/cache" search -x "$name" | grep -q .; then
        echo "MISSING: $name" >&2
        return 1
    fi
    echo "FOUND: $name"
}
require_package luci-proto-xmm
require_package sms-tool
require_package luci-app-modemdata
require_package modemdata
require_package luci-app-sms-tool-js
require_package luci-app-modemband
require_package luci-i18n-modemdata-ru
require_package luci-i18n-sms-tool-js-ru
require_package luci-i18n-modemband-ru

echo "== PASS: feed signatures and required package records verified =="
echo "Note: kmod ABI compatibility and dependency resolution against the exact ImageBuilder root are separate checks."
