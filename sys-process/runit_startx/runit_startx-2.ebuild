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
	SERVICE="tty$i"

	dodir /etc/sv/$SERVICE
	exeinto "/etc/sv/$SERVICE/"
	newexe "${FILESDIR}/run"    run
	newexe "${FILESDIR}/finish" finish
	dosym /run/sv/$SERVICE/supervise /etc/sv/$SERVICE/supervise

	dodir /etc/runit/runsvdir/multi
	dosym /etc/sv/$SERVICE /etc/runit/runsvdir/multi/$SERVICE


	# install log for the service
	dosym /run/sv/$SERVICE/log/supervise /etc/sv/$SERVICE/log/supervise

	exeinto /etc/sv/$SERVICE/log
	newexe $FILESDIR/log.run    run
	newexe $FILESDIR/log.config config
	sed -i -e "s:servicename:$SERVICE:" $D/etc/sv/$SERVICE/log/{run,config}
}
