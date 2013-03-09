# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-python/eselect-python-99999999.ebuild,v 1.7 2012/04/26 14:53:20 aballier Exp $

EAPI=5

inherit eutils autotools subversion
ESVN_REPO_URI="svn://repo.hu/frtplot/trunk"

DESCRIPTION="Free Real-time Data Plotter"
HOMEPAGE="http://frtplot.port70.net/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
S="${WORKDIR}/${MY_P}/src"


RDEPEND="media-libs/libsdl"
DEPEND="${RDEPEND}"

src_prepare() {
	find . -name Makefile -exec sed -i -e 's/-fnested-functions//g' \{\} \;
}

src_compile() {
	cd ${S}/src
	# adding this flag below as recommended by
	#  http://www.gentoo.org/proj/en/hardened/gnu-stack.xml
	#  is not helping.
	#  As per http://www.gentoo.org/proj/en/hardened/gnu-stack.xml?style=printable
	#  it is related to nested functions, emailed upstream
	#  about it
	#append-flags -Wa,--noexecstack
	emake
}

src_install() {
	cd ${S}/src
	# adding this flag below as recommended by
	#  http://www.gentoo.org/proj/en/hardened/gnu-stack.xml
	#  is not helping.
	#  As per http://www.gentoo.org/proj/en/hardened/gnu-stack.xml?style=printable
	#  it is related to nested functions, emailed upstream
	#  about it
	#append-flags -Wa,--noexecstack
	emake install_root="${D}" install
}
