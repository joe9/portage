# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils flag-o-matic
if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="svn://svn.savannah.gnu.org/nano/trunk/nano"
	inherit subversion
else
	MY_PN="nano"
	MY_P=${MY_PN}-${PV/_}
	SRC_URI="http://www.nano-editor.org/dist/v${PV:0:3}/${MY_P}.tar.gz"
fi

DESCRIPTION="nano static binary for initramfs or emergency usage"
HOMEPAGE="http://www.nano-editor.org/ http://www.gentoo.org/doc/en/nano-basics-guide.xml"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="-debug -justify ncurses -slang -unicode"

RDEPEND=">=sys-libs/ncurses-5.9-r1[static-libs,unicode?]
	!ncurses? ( slang? ( sys-libs/slang ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
	unpack ${A}
	mv -v * "$S"
}

src_configure() {
	append-ldflags -static
	econf \
		--bindir="${EPREFIX}"/bin \
		--disable-color \
		--disable-multibuffer \
		--disable-speller \
		--disable-nls \
		$(use_enable justify) \
		$(use_enable debug) \
		$(use_enable unicode utf8) \
		--enable-tiny \
		$(usex ncurses --without-slang $(use_with slang))
}

src_compile() {
	emake
}

src_install() {
	mv -v "$S/src/nano" "$S/src/nano.static"
	exeinto "/bin"
	doexe   "${S}/src/nano.static"
}
