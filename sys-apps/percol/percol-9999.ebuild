# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

# PYTHON_COMPAT=( python2_7 )
# PYTHON_COMPAT=( python3_3 )
PYTHON_COMPAT=( python2_7 python3_3 )

inherit git-2 distutils-r1

DESCRIPTION="Adds flavor of interactive selection to the traditional pipe concept on UNIX"
HOMEPAGE="https://github.com/mooz/percol"
EGIT_REPO_URI=$HOMEPAGE
EGIT_BRANCH="master"

LICENSE=""
SLOT="0"
KEYWORDS=""

RDEPEND="dev-python/six[${PYTHON_USEDEP}]
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
