# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# check https://gpo.zugaina.org/dev-python/percol for ideas
EAPI="6"

# percol currently supports only Python 2.x
# https://github.com/mooz/percol#installation
PYTHON_COMPAT=( python2_7 )

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
