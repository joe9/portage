# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit savedconfig toolchain-funcs git-2 eutils

DESCRIPTION="Dynamic virtual terminal manager"
HOMEPAGE="http://www.brain-dump.org/projects/dvtm/"
EGIT_REPO_URI="git://repo.or.cz/dvtm.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="unicode"

DEPEND="sys-libs/ncurses[unicode?]"
RDEPEND=${DEPEND}

src_prepare() {
	sed -i \
		-e 's|FLAGS =|FLAGS +=|' \
		-e 's|-I/usr/local/include||' \
		-e 's|-L/usr/local/lib||' \
		-e 's|-Os||' \
		config.mk || die "sed config.mk failed"
	use unicode || {
		sed -i \
			-e 's|-lncursesw|-lncurses|' \
			config.mk || die "sed config.mk failed"
	}
	sed -i \
		-e '/strip/d' \
		-e 's:@tic :@tic -o ${ED}/usr/share/terminfo :g' \
		Makefile || die "sed Makefile failed"
	#epatch "${FILESDIR}/sitm.patch"
	cp ${FILESDIR}/dvtm.info ./

	restore_config config.h
}

src_compile() {
	local msg=""
	use savedconfig && msg=", please check the configfile"
	emake CC=$(tc-getCC) ${PN} || die "emake failed${msg}"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install

	insinto /usr/share/${PN}
	newins config.h ${PF}.config.h

	dodoc README

	save_config config.h
}

pkg_postinst() {
	elog "This ebuild has support for user defined configs"
	elog "Please read this ebuild for more details and re-emerge as needed"
	elog "if you want to add or remove functionality for ${PN}"
}
