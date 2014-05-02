# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/proxychains/proxychains-4.2.0.ebuild,v 1.4 2013/02/14 22:13:41 ago Exp $

EAPI="5"

inherit vcs-snapshot toolchain-funcs eutils multilib

DESCRIPTION="force any tcp connections to flow through a proxy (or proxy chain)"
HOMEPAGE="http://sourceforge.net/projects/proxychains-ng/ https://github.com/rofl0r/proxychains-ng"
SRC_URI="https://github.com/rofl0r/proxychains-ng/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}"/${P}-configure.patch
	epatch "${FILESDIR}"/${P}-makefile.patch
	sed -i "s/^\(LDSO_SUFFIX\).*/\1 = so.${PV}/" Makefile || die
	tc-export CC
	mv src/proxychains.conf src/proxychains-ng.conf
	mv src/libproxychains.c src/libproxychains-ng.c
	sed -i "s/proxychains\.conf/proxychains-ng.conf/" src/common.h || die
}

src_install() {
	dobin ${PN}
	dodoc AUTHORS ChangeLog README TODO

	dolib.so lib${PN}.so.${PV}
	dosym lib${PN}.so.${PV} /usr/$(get_libdir)/lib${PN}.so.${PV:0:1}
	dosym lib${PN}.so.${PV} /usr/$(get_libdir)/lib${PN}.so

	insinto /etc
	doins src/${PN}.conf
}
