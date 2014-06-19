# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-2 toolchain-funcs eutils multilib

DESCRIPTION="force any tcp connections to flow through a proxy (or proxy chain)"
HOMEPAGE="http://sourceforge.net/projects/proxychains-ng/ https://github.com/rofl0r/proxychains-ng"
EGIT_REPO_URI="git://github.com/rofl0r/proxychains-ng.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
