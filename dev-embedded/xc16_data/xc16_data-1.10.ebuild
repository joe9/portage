# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-embedded/pk2cmd/pk2cmd-1.20.ebuild,v 1.4 2012/05/25 08:01:20 ssuominen Exp $

EAPI="5"

inherit eutils toolchain-funcs

DESCRIPTION="MPLAB C Compiler for PIC24 and dsPIC DSCs"

HOMEPAGE="http://www.microchip.com/"
# got this idea from
#  https://aur.archlinux.org/packages.php?ID=59174
# synced the build with the arch pkgbuild at
#  https://aur.archlinux.org/packages.php?ID=39085
SRC_URI="http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v${PV}-linux.tar"

LICENSE="MicroChip-PK2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}"

src_install() {
	if [[ "$(uname -m)" != "x86_64" ]]
	then
		# echo "This port does not work on x86_64 machines"
		# exit 1;
		# Copy the device files
		instdir=/opt/microchip/xc16/v${version}
		installer=xc16-v${version}-linux.run

		mkdir -p "$D/$instdir"
		chmod 0755 "$S/$installer"
		# cp $SRC/$installer $D/

		cd "$D"
		echo -e "i\n\n\n\n\n\n\n\n\n\n\n\n\n\ny\n\n\n\ny\n\n$D$instdir\ny\ni\ni\ni\ni" > "$D/inst_input"
		mkdir -p "$D/home"
		ln -sf /var/pkgmk/work/xc16-bin/pkg/opt/microchip /opt/microchip
		# HOME=$D/home $SRC/$installer --mode text < $D/inst_input &> /dev/null
		HOME=$D/home "$S/$installer" --mode text < "$D/inst_input"
		rm /opt/microchip

		rm "$D/inst_input"
		rm -r "$D/home"

		mkdir -p "$D/usr/share/pic30/bin"
		mv "$D/opt/microchip/xc16/v1.10/bin/device_files"     "$D/usr/share/pic30/bin/"
		mv "$D/opt/microchip/xc16/v1.10/bin/c30_device.info"  "$D/usr/share/pic30/bin/"
		mv "$D/opt/microchip/xc16/v1.10/support"              "$D/usr/share/pic30/"
		# mv "$D/opt/microchip/xc16/v1.10/include"            "$D/usr/share/pic30/"

		rm -r "$D/opt"
	else
		mkdir -p "${D}/usr/share/pic30/"
		cp --archive "${FILESDIR}/${PV}/bin"     "${D}/usr/share/pic30/"
		cp --archive "${FILESDIR}/${PV}/support" "${D}/usr/share/pic30/"
	fi
}
