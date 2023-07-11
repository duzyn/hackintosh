#!/usr/bin/env bash

# A simple script to setup up a new ubuntu installation.
# Inspired by https://github.com/trxcllnt/ubuntu-setup/

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump | gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default.
: "${DEBUG:="false"}"
[[ "$DEBUG" == "true" ]] && set -o xtrace

SCRIPT_DIR="$(dirname "$(readlink -f "${0}")")"

mkdir -p "$SCRIPT_DIR/downloads"

download_github_releases_kexts() {
    local REPO_NAME PACKAGE_NAME API_URL
    REPO_NAME="$1"
    PACKAGE_NAME="$(basename $REPO_NAME)"
    API_URL="https://api.github.com/repos/$REPO_NAME/releases/latest"

    if [[ ! -e "$SCRIPT_DIR/downloads/$PACKAGE_NAME.json" ]]; then
        wget -q -O "$SCRIPT_DIR/downloads/$PACKAGE_NAME.json" "$API_URL"
    fi

    # VERSION_LATEST="$(jq -r ".tag_name" "$SCRIPT_DIR/downloads/$PACKAGE_NAME.json" | tr -d "v")"

    jq -r ".assets[].browser_download_url" "$SCRIPT_DIR/downloads/$PACKAGE_NAME.json" | \
        grep "RELEASE.zip" | head -n 1 | \
        sed -e "s|https://github.com|https://ghproxy.com/github.com|g" | \
        xargs wget -N -P "$SCRIPT_DIR/downloads"
}

download_github_releases_kexts acidanthera/OpenCorePkg
download_github_releases_kexts acidanthera/AppleALC
download_github_releases_kexts acidanthera/BrightnessKeys
download_github_releases_kexts acidanthera/CPUFriend
download_github_releases_kexts acidanthera/FeatureUnlock
download_github_releases_kexts acidanthera/HibernationFixup
download_github_releases_kexts acidanthera/Lilu
download_github_releases_kexts acidanthera/NVMeFix
download_github_releases_kexts acidanthera/VirtualSMC
download_github_releases_kexts acidanthera/VoodooInput
download_github_releases_kexts acidanthera/VoodooPS2
download_github_releases_kexts acidanthera/WhateverGreen

wget -N -P "$SCRIPT_DIR/downloads" https://ghproxy.com/https://github.com/acidanthera/OcBinaryData/archive/refs/heads/master.zip

echo "Completed!"
exit 0
