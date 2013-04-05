# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-embedded/pk2cmd/pk2cmd-1.20.ebuild,v 1.4 2012/05/25 08:01:20 ssuominen Exp $

EAPI="5"

inherit eutils toolchain-funcs

DESCRIPTION="An application for working with the Microchip PicKit2 PIC programmer"
HOMEPAGE="http://www.microchip.com/pickit2"
# got this idea from
#  https://aur.archlinux.org/packages.php?ID=61152
SRC_URI="http://ww1.microchip.com/downloads/en/DeviceDoc/PICkit2_PK2CMD_WIN32_SourceV1-21_RC1.zip"

LICENSE="MicroChip-PK2"
SLOT="0"
KEYWORDS="~ppc ~ppc64 ~amd64 ~x86"

DEPEND="virtual/libusb:0
		dev-embedded/pk2df"
RDEPEND="${DEPEND}"

# S="${WORKDIR}/${PN}/${PN}"
S="${WORKDIR}/${PN}"

src_prepare() {
	# find . -type f -exec dos2unix {} \;

	cp "${FILESDIR}/60-pickit2.rules" "$S/release/"
	# Patch adds /usr/share/pk2 to the default search for the device file
	cd "${PN}"
	# epatch "${FILESDIR}/${PN}-add-share-dir-for-dev-file-${PV}.patch"
	epatch "${FILESDIR}/${PN}-add-share-dir-for-dev-file-${PV}.patch"
	# cd "${PN}"
	# epatch "${FILESDIR}/pk2_devicefile_osfile_paths.patch"
	# cd "${S}"
	# patch --merge -p0 -i $SRC/verbose.patch
	# patch --merge -p0 -i $SRC/usb_debug.patch

	# Fix up the Makefile
	sed -i 's:#TARGET=linux:TARGET=linux:' Makefile
	sed -i 's:DBG=-O2:DBG=:' Makefile
	sed -i 's:^CFLAGS=:CFLAGS+=:' Makefile
	sed -i 's:^LDFLAGS=:LDFLAGS+=:' Makefile
	sed -i 's:^LIBUSB=/usr/local:LIBUSB=/usr:' Makefile
	sed -i "s:^CC=g++::" Makefile
}

src_compile() {
	cd "${S}/${PN}"
	emake CC="$(tc-getCXX)" linux || die "emake failed"
}

src_install() {
	# Copy the device files and PicKit2 OS
	cd "${S}/release"
	insinto "/usr/share/pk2"
	# doins PK2DeviceFile.dat
	doins PK2V023200.hex
	# Install the udev rules
	insinto "/lib/udev/rules.d"
	doins 60-pickit2.rules
	# Install the program
	exeinto /usr/bin
	cd "${S}/${PN}"
	doexe pk2cmd
	# Install the documentation
	cd "${S}"
	# dodoc ReadmeForPK2CMDLinux2-6.txt
	dodoc release/ReadmeForPK2CMDLinux2-6.txt
}
