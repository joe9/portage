# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/geda/geda-1.8.1.ebuild,v 1.1 2012/12/05 14:21:47 tomjbe Exp $

EAPI=5
inherit eutils git-2

MY_PN=${PN}-gaf
MY_P=${MY_PN}-${PV}

DESCRIPTION="GPL Electronic Design Automation (gEDA):gaf core package"
HOMEPAGE="http://www.gpleda.org/"
EGIT_REPO_URI="git://git.geda-project.org/geda-gaf.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug doc examples nls stroke threads"

CDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	>=x11-libs/cairo-1.2.0
	>=dev-scheme/guile-1.8[deprecated]
	nls? ( virtual/libintl )
	stroke? ( >=dev-libs/libstroke-0.5.1 )"

DEPEND="${CDEPEND}
	sys-apps/groff
	dev-util/desktop-file-utils
	x11-misc/shared-mime-info
	virtual/pkgconfig
	nls? ( >=sys-devel/gettext-0.16 )"

RDEPEND="${CDEPEND}"

	#sci-electronics/electronics-menu

src_prepare() {
	./autogen.sh || die
	if ! use doc ; then
		#sed -i -e '/^SUBDIRS = /s/docs//' Makefile.in || die
		sed -i -e 's/ docs examples$/ examples/' Makefile.in || die
		sed -i -e '/^SUBDIRS = /s/documentation//' symbols/Makefile.in || die
	fi
	if ! use examples ; then
		sed -i -e 's/ examples$//' Makefile.in || die
	fi
}

src_configure() {
	econf \
		--docdir=/usr/share/doc/${PF} \
		--mandir=/usr/share/man/${PF} \
		$(use_enable threads threads posix) \
		$(use_enable nls) \
		--disable-update-xdg-database \
		--disable-doxygen
}
