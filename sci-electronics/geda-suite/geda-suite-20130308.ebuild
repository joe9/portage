# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-electronics/geda-suite/geda-suite-20110427.ebuild,v 1.2 2011/07/15 22:49:54 calchan Exp $

HOMEPAGE="http://www.geda-project.org"
DESCRIPTION="Metapackage which installs all the components required for a full-featured gEDA/gaf system"

IUSE=''
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"

RDEPEND="sci-electronics/geda
	>=sci-electronics/pcb
	sci-electronics/gerbv
	>=sci-electronics/xgsch2pcb
	>=sci-electronics/gnucap
	>=sci-electronics/iverilog
	sci-electronics/gspiceui
	sci-electronics/gtkwave
	>=sci-electronics/gwave
	sci-electronics/ngspice"
