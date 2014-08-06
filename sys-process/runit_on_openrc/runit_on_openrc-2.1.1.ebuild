# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/runit/runit-2.1.1-r1.ebuild,v 1.2 2012/02/06 03:13:33 vapier Exp $

EAPI="5"

inherit toolchain-funcs flag-o-matic

DESCRIPTION="A UNIX init scheme with service supervision leveraging openrc services"
HOMEPAGE="http://smarden.org/runit/"
MY_PN="runit"
MY_P=${MY_PN}-${PV}
SRC_URI="http://smarden.org/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="dietlibc static"

RDEPEND="
	dietlibc? ( dev-libs/dietlibc )
	app-shells/dash
	sys-apps/openrc
	virtual/daemontools
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/admin/${MY_P}/src"

# check https://wiki.archlinux.org/index.php/Runit for
#	more details on runit usage

src_prepare() {
	# we either build everything or nothing static
	sed -i -e 's:-static: :' Makefile

	# set default service path to /var/service
	sed -i \
	 -e 's:^char \*varservice ="/service/";$:char \*varservice ="/run/service/";:' \
	 sv.c
	sed -i \
	-e 's,^#define STOPIT "/etc/runit/stopit"$,#define STOPIT "/run/runit/stopit",' \
	-e 's,^#define REBOOT "/etc/runit/reboot"$,#define REBOOT "/run/runit/reboot",' \
		runit.h
	sed -i -e 's,/etc/runit/runsvdir,/run/runit/runsvdir,g' runsvchdir.c
	# patch -i $S/use_var_run_directory_for_current_and_previous.patch
	sed -i \
		-e 's,/etc/runit/stopit,/run/runit/stopit,g' \
		-e 's,/etc/runit/reboot,/run/runit/reboot,g' \
		-e 's,/etc/runit/runsvdir/previous,/run/runit/runsvdir/previous,g' \
		-e 's,/etc/runit/runsvdir/current,/run/runit/runsvdir/current,g' \
		-e 's,/etc/runit/runsvdir/current.new,/run/runit/runsvdir/current.new,g' \
		../man/*
	sed -i -e 's,/etc/runit/stopit,/run/runit/stopit,g' \
			-e 's,/etc/runit/reboot,/run/runit/reboot,g' \
			"${S}/../etc/debian/ctrlaltdel"
}

src_configure() {
	local diet=""
	use dietlibc && diet="diet -Os"
	use static && append-ldflags -static

	echo "${diet} $(tc-getCC) ${CFLAGS}"  > conf-cc
	echo "${diet} $(tc-getCC) ${LDFLAGS}" > conf-ld
}

#src_compile() {
#	cd ${S}/src
#	emake
#	#emake check
#}

install_service() {
	# $1 == install to multi?
	# $2 == service name
	# $3 == run file name
	# $4 == finish file name, optional parameter
	if [ -n "$2" -a -n "$3" ]
	then
		TO_MULTI="$1"
		SERVICE="$2"
		RUN_FILE_NAME="$3"
		FINISH_FILE_NAME="$4"

		echo "installing service: $SERVICE"

		#dodir /etc/sv/$SERVICE/log/supervise
		# ln -s /etc/sv/$SERVICE $PKG/etc/runit/runsvdir/multi/
		# ln -s /etc/sv/$SERVICE $PKG/etc/runit/runsvdir/single/

		dosym /run/sv/$SERVICE/supervise /etc/sv/$SERVICE/supervise

		exeinto /etc/sv/$SERVICE
		newexe "${FILESDIR}/${RUN_FILE_NAME}" run

		if [ -n "$FINISH_FILE_NAME" ]
		then
			exeinto /etc/sv/$SERVICE
			newexe $FILESDIR/$FINISH_FILE_NAME finish
		fi

		if [ -n "$TO_MULTI" ]
		then
		dosym /etc/sv/$SERVICE /etc/runit/runsvdir/multi/$SERVICE
		   if [ "$TO_MULTI" == "both" ]
		   then
			dosym /etc/sv/$SERVICE /etc/runit/runsvdir/single/$SERVICE
		   fi
		fi

		# install log for the service
		dosym /run/sv/$SERVICE/log/supervise /etc/sv/$SERVICE/log/supervise

		exeinto /etc/sv/$SERVICE/log
		newexe $FILESDIR/log.run    run
		newexe $FILESDIR/log.config config
		sed -i -e "s:servicename:$SERVICE:" $D/etc/sv/$SERVICE/log/{run,config}
	fi
}

src_install() {
	# default services
	dodir /etc/runit{,/runsvdir{,/ttys,/single,/multi}}

	# man-pages
	doman ${S}/../man/*

	exeinto /etc/runit
	doexe   ${FILESDIR}/[123]
	doexe   "${S}/../etc/debian/ctrlaltdel"

	# add gettys for 1-6 terminals
	for i in {1..5}
	do
		dodir /etc/sv/tty$i
		dodir /etc/runit/runsvdir
		dosym /etc/sv/tty$i /etc/runit/runsvdir/multi/tty$i
		dosym /etc/sv/tty$i /etc/runit/runsvdir/single/tty$i
		dosym /etc/sv/tty$i /etc/runit/runsvdir/ttys/tty$i

		dosym /run/sv/tty$i/supervise /etc/sv/tty$i/supervise

		exeinto "/etc/sv/tty$i/"
		newexe "${FILESDIR}/run.ttyX"    run
		newexe "${FILESDIR}/finish.ttyX" finish
		sed -i -e "s:ttyX:tty$i:g" $D/etc/sv/tty$i/{run,finish}
	done
	sed -i -e "s:/sbin/agetty:/sbin/agetty --noclear:g" $D/etc/sv/tty1/run

	# install services
	install_service both  syslogd run.syslogd
	install_service both  klogd   run.klogd
	install_service multi atd     run.atd
	install_service multi crond   run.crond
	install_service multi acpid   run.acpid

	# insinto /etc/sv/acpid/
	# doins ${FILESDIR}/acpi_event_power

	into /
	dosbin $(<${S}/../package/commands)
	into /usr/
}
