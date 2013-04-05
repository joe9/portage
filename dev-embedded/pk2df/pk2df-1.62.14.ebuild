# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-embedded/pk2cmd/pk2cmd-1.20.ebuild,v 1.4 2012/05/25 08:01:20 ssuominen Exp $

EAPI="5"

inherit eutils toolchain-funcs

DESCRIPTION="Microchip PicKit2 PIC programmer: New device support file. Compatible with PICkit 2 v2.61"

HOMEPAGE="http://www.microchip.com/pickit2"
# got this idea from
#  https://aur.archlinux.org/packages.php?ID=61152
SRC_URI="http://ww1.microchip.com/downloads/en/DeviceDoc/PK2DFUpdate-1-62-14.zip"

LICENSE="MicroChip-PK2"
SLOT="0"
KEYWORDS="~ppc ~ppc64 ~amd64 ~x86"

DEPEND="virtual/libusb:0"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	# Copy the device files and PicKit2 OS
	insinto "/usr/share/pk2"
	doins PK2DeviceFile.dat
}
