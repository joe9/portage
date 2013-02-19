# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/runit/runit-2.1.1-r1.ebuild,v 1.2 2012/02/06 03:13:33 vapier Exp $

EAPI="5"

inherit toolchain-funcs

DESCRIPTION="start X from agetty with runit init scheme"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

RDEPEND="
	sys-process/runit_on_openrc
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	# add gettys for 1-6 terminals
	i=6

	dodir /etc/sv/tty$i
	exeinto "/etc/sv/tty$i/"
	newexe "${FILESDIR}/run"    run
	newexe "${FILESDIR}/finish" finish
	dosym /run/sv/tty$i/supervise /etc/sv/tty$i/supervise

	dodir /etc/runit/runsvdir/multi
	dosym /etc/sv/tty$i /etc/runit/runsvdir/multi/tty$i
}
