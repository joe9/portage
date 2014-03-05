# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit autotools eutils fdo-mime gnome2-utils toolchain-funcs git-2

DESCRIPTION="GPL Electronic Design Automation: Printed Circuit Board editor"
HOMEPAGE="http://www.gpleda.org/"
EGIT_REPO_URI="git://git.geda-project.org/pcb.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="dbus debug doc gcode gif +gtk jpeg m4lib-png motif nelma nls opengl png test tk toporouter xrender"
DOCS="AUTHORS README NEWS ChangeLog"

CDEPEND="gif? ( >=media-libs/gd-2.0.23 )
	gtk? ( x11-libs/gtk+:2 x11-libs/pango
		x11-libs/gtkglext
		dbus? ( sys-apps/dbus ) )
	jpeg? ( >=media-libs/gd-2.0.23[jpeg] )
	motif? ( !gtk? (
		>=x11-libs/motif-2.3:0
		dbus? ( sys-apps/dbus )
		xrender? ( >=x11-libs/libXrender-0.9 ) ) )
	nelma? ( >=media-libs/gd-2.0.23 )
	opengl? ( virtual/opengl )
	gcode? ( >=media-libs/gd-2.0.23 )
	nls? ( virtual/libintl )
	png? ( >=media-libs/gd-2.0.23[png] )
	m4lib-png? ( >=media-libs/gd-2.0.23[png] )
	tk? ( >=dev-lang/tk-8 )"

DEPEND="${CDEPEND}
	test? (
		|| ( media-gfx/graphicsmagick[imagemagick] media-gfx/imagemagick )
		sci-electronics/gerbv
	)
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	sys-devel/gettext"

RDEPEND="${CDEPEND}
	sci-electronics/electronics-menu"

REQUIRED_USE=" ?? ( gtk motif )
	 dbus? ( || ( gtk motif ) )
	 opengl? ( gtk )
	 xrender? ( motif ) "

pkg_pretend() {
	if ! use gtk  && ! use motif; then
		ewarn "${P} is being built without a GUI, make sure you know what you're doing!  Otherwise please enable GTK or MOTIF use flags"
	fi
}

src_prepare() {
	if use test; then
		# adapt the list of tests to run according to USE flag settings
		use png || sed -i '/^hid_png/d' tests/tests.list || die
		use gcode || sed -i '/^hid_gcode/d' tests/tests.list || die
	fi

	# eautoreconf is running without errors without the below sed
	# replacement. Leave this line commented if the need arises later.
	# fix bad syntax in Makefile.am and configure.ac before running eautoreconf
	# sed -i -e 's/:=/=/' Makefile.am || die

	eautoreconf
}

src_configure() {
	local myconf
	if use gtk ; then
		myconf="--with-gui=gtk $(use_enable dbus) $(use_enable opengl gl) --disable-xrender"
	elif use motif ; then
		use opengl && einfo "Ignoring opengl use flag, requires gtk"
		myconf="--with-gui=lesstif $(use_enable dbus) $(use_enable xrender) --disable-gl"
	else
		use opengl && einfo "Ignoring opengl use flag, requires gtk"
		myconf="--with-gui=batch --disable-xrender --disable-dbus --disable-gl"
	fi

	local exporters="bom gerber ps"
	if use png || use jpeg || use gif; then
		exporters="${exporters} png"
	fi
	use nelma && exporters="${exporters} nelma"
	use gcode && exporters="${exporters} gcode"
	use tk || export WISH="${EPREFIX}/bin/true"

	econf \
		${myconf} \
		$(use_enable doc) \
		$(use_enable gif) \
		$(use_enable jpeg) \
		$(use_enable png) \
		$(use_enable m4lib-png) \
		$(use_enable toporouter) \
		$(use_enable debug) \
		$(use_enable nls) \
		--disable-toporouter-output \
		--with-exporters="${exporters}" \
		--disable-rpath \
		--disable-update-mime-database \
		--disable-update-desktop-database \
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_compile() {
	emake AR="$(tc-getAR)"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
