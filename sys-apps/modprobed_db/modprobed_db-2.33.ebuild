# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MY_PN="modprobed-db"
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Keeps track of EVERY kernel module that has ever been probed. Useful for 'make localmodconfig'"
HOMEPAGE="https://wiki.archlinux.org/index.php/Modprobed_db"
SRC_URI="http://repo-ck.com/source/${MY_PN}/${MY_P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND="virtual/modutils"

src_install() {
	dobin ${PN}
	insinto /etc
	doins ${PN}.conf
	newdoc README* README
	newman ${PN}.manpage ${PN}.1
}
