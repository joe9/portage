# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Keeps track of EVERY kernel module that has ever been probed. Useful for 'make localmodconfig'"
HOMEPAGE="https://wiki.archlinux.org/index.php/Modprobed_db"

MY_PN="${PN/_/-}"
MY_P="${MY_PN}-${PV}"
SRC_URI="http://repo-ck.com/source/${MY_PN}/${MY_P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND="virtual/modutils"

S="${WORKDIR}/${MY_P}"

src_install() {
	dobin common/${MY_PN}
	newman doc/${MY_PN}.8 ${MY_PN}.8
}
