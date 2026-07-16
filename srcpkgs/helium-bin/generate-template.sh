#!/bin/bash

response=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2026-03-10" \
  https://api.github.com/repos/imputnet/helium-linux/releases/latest 2> /dev/null)

version=$(echo "$response" | jq -r '.name')

x86_64_sum=$(echo "$response" | jq -r '.assets[] | select(.name | endswith("-x86_64_linux.tar.xz")) | .digest | split(":")[1]')
aarch64_sum=$(echo "$response" | jq -r '.assets[] | select(.name | endswith("-arm64_linux.tar.xz")) | .digest | split(":")[1]')

cat <<EOF
# Template file for 'helium-bin'
pkgname=helium-bin
version=$version
revision=1
archs="x86_64 aarch64"
short_desc="Private, fast, and honest web browser"
maintainer="al20ov <nicolas.antauf@gmail.com>"
license="GPL-3.0-only"
homepage="https://helium.computer/"

case "\$XBPS_TARGET_MACHINE" in
	x86_64)
		distfiles="https://github.com/imputnet/helium-linux/releases/download/\${version}/helium-\${version}-x86_64_linux.tar.xz"
		checksum=$x86_64_sum
		wrksrc="helium-\${version}-x86_64_linux"
		;;
	aarch64)
		distfiles="https://github.com/imputnet/helium-linux/releases/download/\${version}/helium-\${version}-arm64_linux.tar.xz"
		checksum=$aarch64_sum
		wrksrc="helium-\${version}-arm64_linux"
		;;
esac

do_install() {
	vmkdir usr/lib/helium
	vcopy * usr/lib/helium

	vmkdir usr/bin
	ln -sf /usr/lib/helium/helium \${DESTDIR}/usr/bin/helium

	vinstall helium.desktop 644 usr/share/applications/
	vinstall product_logo_256.png 644 usr/share/icons/hicolor/256x256/apps helium.png
}
EOF
