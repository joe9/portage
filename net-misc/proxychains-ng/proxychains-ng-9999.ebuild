# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-2 toolchain-funcs eutils multilib

DESCRIPTION="force any tcp connections to flow through a proxy (or proxy chain)"
HOMEPAGE="http://sourceforge.net/projects/proxychains-ng/ https://github.com/rofl0r/proxychains-ng"
EGIT_REPO_URI="git://github.com/rofl0r/proxychains-ng.git"

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
	dodoc AUTHORS README TODO

	dolib.so lib${PN}.so.${PV}
	dosym lib${PN}.so.${PV} /usr/$(get_libdir)/lib${PN}.so.${PV:0:1}
	dosym lib${PN}.so.${PV} /usr/$(get_libdir)/lib${PN}.so

	insinto /etc
	doins src/${PN}.conf
}
