#!/bin/sh
set -eu

REL="25.12"
ARCH="aarch64_generic"
ICEG_ROOT="https://raw.githubusercontent.com/4IceG/Modem-extras-apk/main/myapk"
ICEG_ADB="${ICEG_ROOT}/packages.adb"
ICEG_KEY="${ICEG_ROOT}/IceG-apkpub.pem"
PASSWALL_ROOT="https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${REL}/${ARCH}"
PASSWALL_KEY="https://downloads.sourceforge.net/project/openwrt-passwall-build/apk.pub"

apk add --no-cache curl jq openssl

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
KEYS="$WORK/keys"
REPOS="$WORK/repositories"
ROOT="$WORK/root"
CACHE="$WORK/cache"
mkdir -p "$KEYS" "$ROOT/etc/apk" "$ROOT/lib/apk/db" "$CACHE"

fetch_key() {
    url="$1"
    dest="$2"
    curl --fail --silent --show-error --location "$url" --output "$dest"
    test -s "$dest"
    openssl pkey -pubin -in "$dest" -noout
}

echo "== Validate signing keys =="
fetch_key "$ICEG_KEY" "$KEYS/IceG-apkpub.pub"
fetch_key "$PASSWALL_KEY" "$KEYS/passwall.pub"

echo "== Validate signed feed metadata =="
curl --fail --silent --show-error --location "${ICEG_ROOT}/index.json" --output "$WORK/iceg-index.json"
jq -e . "$WORK/iceg-index.json" >/dev/null
for feed in passwall_packages passwall_luci passwall2; do
    curl --fail --silent --show-error --location "${PASSWALL_ROOT}/${feed}/index.json" --output "$WORK/${feed}-index.json"
    jq -e . "$WORK/${feed}-index.json" >/dev/null
done

cat > "$REPOS" <<EOF
${ICEG_ADB}
${PASSWALL_ROOT}/passwall_packages/packages.adb
${PASSWALL_ROOT}/passwall_luci/packages.adb
${PASSWALL_ROOT}/passwall2/packages.adb
EOF

echo "== Verify APK repository signatures =="
apk --version
apk --root "$ROOT" --keys-dir "$KEYS" --repositories-file "$REPOS" --cache-dir "$CACHE" add --initdb
apk --root "$ROOT" --keys-dir "$KEYS" --repositories-file "$REPOS" --cache-dir "$CACHE" --force-refresh update

require_package() {
    name="$1"
    if ! apk --root "$ROOT" --keys-dir "$KEYS" --repositories-file "$REPOS" --cache-dir "$CACHE" search -x "$name" | grep -q .; then
        echo "MISSING: $name" >&2
        return 1
    fi
    echo "FOUND: $name"
}

for pkg in \
    luci-app-3ginfo-lite luci-i18n-3ginfo-lite-ru \
    luci-app-modemdata modemdata luci-i18n-modemdata-ru \
    luci-app-modemband modemband luci-i18n-modemband-ru \
    luci-app-sms-tool-js luci-i18n-sms-tool-js-ru \
    luci-app-passwall2 luci-i18n-passwall2-ru \
    xray-core sing-box v2ray-geoip v2ray-geosite geoview tcping; do
    require_package "$pkg"
done

echo "== PASS: all requested 4IceG and PassWall 2 packages are indexed for ${ARCH} =="
echo "Kernel modules are intentionally excluded from these external feeds; they must come from the FriendlyELEC 6.1.141 build."
