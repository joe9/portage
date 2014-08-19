# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/simple-init/simple-init-9999.ebuild,v 1.12 2014/01/06 21:17:53 jer Exp $

EAPI="5"

inherit eutils git-r3 toolchain-funcs

DESCRIPTION="Simplified init leveraging openrc services"
HOMEPAGE="https://github.com/joe9/init"
EGIT_REPO_URI="https://github.com/joe9/init.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""

RDEPEND="
	sys-apps/openrc
"
DEPEND="${RDEPEND}"

src_install() {
	# default services
	emake DESTDIR="${D}" installrc.X
}
