# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/st/st-9999.ebuild,v 1.6 2012/12/17 21:56:50 xmw Exp $

EAPI=3

inherit git-2 savedconfig toolchain-funcs eutils

DESCRIPTION="simple terminal implementation for X"
HOMEPAGE="http://st.suckless.org/"
EGIT_REPO_URI="git://git.suckless.org/st"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}
	sys-libs/ncurses"

pkg_setup() {
	elog "Please ensure an usable font is installed, like"
	elog "    media-fonts/corefonts"
	elog "    media-fonts/dejavu"
	elog "    media-fonts/urw-fonts"
}

src_prepare() {
	sed -e '/^CFLAGS/s:[[:space:]]-Wall[[:space:]]: :' \
		-e '/^CFLAGS/s:[[:space:]]-O[^[:space:]]*[[:space:]]: :' \
		-e '/^LDFLAGS/{s:[[:space:]]-s[[:space:]]: :}' \
		-e '/^X11INC/{s:/usr/X11R6/lib:/usr/include/X11:}' \
		-e '/^X11LIB/{s:/usr/X11R6/lib:/usr/lib/X11:}' \
		-i config.mk || die
	tc-export CC

	restore_config config.h
	epatch \
	 "$FILESDIR/0001-ensure-that-the-italic-font-has-the-same-weight-as-t.patch"
	# "$FILESDIR/0001-added-slant-and-weight-to-dc.ifont-dc.ibfont-and-dc..patch"
}

src_install() {
	emake DESTDIR="${D}" X11INC="/usr/include/X11" X11LIB="/usr/lib/X11" PREFIX="${EPREFIX}"/usr install || die
	tic -s -o "${ED}"/usr/share/terminfo st.info || die
	dodoc TODO || die

	save_config config.h
}
