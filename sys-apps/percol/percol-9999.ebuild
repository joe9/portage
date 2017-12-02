# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

# PYTHON_COMPAT=( python2_7 )
# https://wiki.gentoo.org/wiki/Project:Python/Implementations
# pytho3.4 is the current stable
PYTHON_COMPAT=( python3_{4,5} )
# PYTHON_COMPAT=( python2_7 python3_4 )

inherit git-r3 distutils-r1

DESCRIPTION="Adds flavor of interactive selection to the traditional pipe concept on UNIX"
HOMEPAGE="https://github.com/mooz/percol"
EGIT_REPO_URI=$HOMEPAGE
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

RDEPEND="dev-python/six[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
dev-python/setuptools[${PYTHON_USEDEP}]"
