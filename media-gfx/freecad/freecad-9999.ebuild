# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit multilib fortran-2 python-single-r1 cmake-utils git-2

DESCRIPTION="QT based Computer Aided Design application"
HOMEPAGE="http://www.freecadweb.org/"
EGIT_REPO_URI="git://git.code.sf.net/p/free-cad/code"
# EGIT_REPO_URI="git://github.com/FreeCAD/FreeCAD_sf_master"
EGIT_PROJECT="${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# https://bugs.gentoo.org/show_bug.cgi?id=474794
#	<=sci-libs/opencascade-6.5.5
RDEPEND="dev-cpp/eigen:3
	dev-games/ode
	dev-libs/boost
	dev-libs/libf2c
	dev-libs/libspnav[X]
	dev-libs/xerces-c[icu]
	dev-python/PyQt4[svg,${PYTHON_USEDEP}]
	dev-python/pivy[${PYTHON_USEDEP}]
	dev-qt/qtgui:4
	dev-qt/qtopengl:4
	dev-qt/qtsvg:4
	dev-qt/qtwebkit:4
	dev-qt/qtxmlpatterns:4
	dev-qt/designer
	media-libs/SoQt
	media-libs/coin[doc]
	sci-libs/gts
	sci-libs/opencascade
	sys-libs/zlib
	virtual/glu"
DEPEND="${RDEPEND}
	dev-python/pyside[${PYTHON_USEDEP}]
		${PYTHON_DEPS}
	>=dev-lang/swig-2.0.4-r1:0"

# http://bugs.gentoo.org/show_bug.cgi?id=352435
# http://www.gentoo.org/foundation/en/minutes/2011/20110220_trustees.meeting_log.txt
RESTRICT="bindist mirror"

pkg_setup() {
	fortran-2_pkg_setup
	python-single-r1_pkg_setup
}

src_configure() {
	local my_occ_env=${EROOT}etc/env.d/50opencascade
	if [ -e "${EROOT}etc/env.d/51opencascade" ] ; then
		my_occ_env=${EROOT}etc/env.d/51opencascade
	fi
	export CASROOT=$(sed -ne '/^CASROOT=/{s:.*=:: ; p}' $my_occ_env)

	local mycmakeargs=(
		-DOCC_INCLUDE_DIR="${CASROOT}"/inc
		-DOCC_INCLUDE_PATH="${CASROOT}"/inc
		-DOCC_LIBRARY="${CASROOT}"/lib/libTKernel.so
		-DOCC_LIBRARY_DIR="${CASROOT}"/lib
		-DOCC_LIB_PATH="${CASROOT}"/lib
		-DCOIN3D_INCLUDE_DIR="${EROOT}"usr/include/coin
		-DCOIN3D_LIBRARY="${EROOT}"usr/$(get_libdir)/libCoin.so
		-DSOQT_LIBRARY="${EROOT}"usr/$(get_libdir)/libSoQt.so
		-DSOQT_INCLUDE_PATH="${EROOT}"usr/include/coin
		-DCMAKE_BINARY_DIR="${EROOT}"usr/bin
		-DCMAKE_INSTALL_PREFIX="${EROOT}"usr/$(get_libdir)/${PN}
	)
	cmake-utils_src_configure
	ewarn "${P} will be built against opencascade version ${CASROOT}"
}

src_install() {
	cmake-utils_src_install

	prune_libtool_files

	dosym /usr/$(get_libdir)/${PN}/bin/FreeCAD /usr/bin/FreeCAD
	dosym /usr/$(get_libdir)/${PN}/bin/FreeCADCmd /usr/bin/FreeCADCmd
	# dosym "/usr/$(get_libdir)/${PN}/bin/FreeCAD" "/usr/bin/freecad"
	dosym "/usr/$(get_libdir)/${PN}/bin/FreeCAD" "/usr/bin/${PN}"

	dodoc README.Linux ChangeLog.txt
}
