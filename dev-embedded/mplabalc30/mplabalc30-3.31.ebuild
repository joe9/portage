# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-embedded/pk2cmd/pk2cmd-1.20.ebuild,v 1.4 2012/05/25 08:01:20 ssuominen Exp $

EAPI="5"

inherit autotools-utils eutils multibuild toolchain-funcs

# downloaded the files/*.diff files from
#  http://david.lutolf.net/dt/pic_microchip/dist/pic30-binutils-3.11b.tar.bz2
# synced the build with the arch pkgbuild at
#  https://aur.archlinux.org/packages.php?ID=39084
#  https://aur.archlinux.org/packages.php?ID=39085
# arch pkgbuild file saved as mplabalc30.PKGBUILD
DESCRIPTION="MPLAB ASM30 Assembler"
HOMEPAGE="http://www.microchip.com"
MY_PV=${PV//./_}
SRC_URI="http://ww1.microchip.com/downloads/en/DeviceDoc/${PN}v${MY_PV}.tar.gz"

LICENSE="MicroChip-PK2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

PDEPEND="dev-embedded/xc16_data"
DEPEND="app-text/dos2unix"

MULTIBUILD_VARIANTS=( coff elf )
S="${WORKDIR}"

src_prepare() {
	# There is a problem with finding the resource file
	# Here we add some alternatives locations.
	# Only those places will be searched before giving up
	#echo	 "char *pic30_resource_files[] = {"  		 >acme/c30_device_info_path.h
	#echo	 "\"/usr/share/pic30/c30_device.info\","	 >>acme/c30_device_info_path.h
	#echo	 "\"/usr/share/pic30/bin/c30_device.info\"," >>acme/c30_device_info_path.h
	#echo	 "0};"										 >>acme/c30_device_info_path.h
	# <mgorny> <<-_EOF_ is heredoc
	# <mgorny> everything from next line to _EOF_ is put into that file
	# <mgorny> plus the '-' makes it strip leading whitespace
	cat > acme/c30_device_info_path.h <<-_EOF_ || die
		char *pic30_resource_files[] = {
			"/usr/share/pic30/c30_device.info",
			"/usr/share/pic30/bin/c30_device.info",
			0
		};
	_EOF_

	echo "#define MCHP_VERSION v${PV} for Gentoo Linux" \
		>acme/mchp_version.h || die

	find . -type f -exec dos2unix --force {} \;

	# epatch "${FILESDIR}/allow-empty-device-info-file.diff"
	epatch "${FILESDIR}/binutils-makefile_in.diff"

	# the below files from arch build
	epatch "${FILESDIR}/sbrk.patch"
	epatch "${FILESDIR}/relocation-fix.patch"
	epatch "${FILESDIR}/morediffs.patch"
	# epatch "${FILESDIR}/search-path-fix.diff"
	epatch "${FILESDIR}/c30_resource-paths.patch"
	epatch "${FILESDIR}/resource.patch"
	epatch "${FILESDIR}/cpu-pic30.c.patch"
	# unused patch file from the arch build
	#  default-path.patch

	# cp --archive acme acme.elf
#	find acme -name *.y -type f -exec touch '{}' ';'
#	find acme -name *.l -type f -exec touch '{}' ';'
#	find acme.elf -name *.y -type f -exec touch '{}' ';'
#	find acme.elf -name *.l -type f -exec touch '{}' ';'
#	<mgorny> next one: i collapsed the two finds to one
#	<mgorny> since the matched files differ only by one letter,
#		it's easy to match them with *.[ly]
#	<joe9> mgorny: yes, saw that. cool. I was a little unsure
#		about patterns in an ebuild.
#	<joe9> as I was not sure which shell it uses.
#	<mgorny> you need to know where to quote them
#	<mgorny> bash
#	<mgorny> bash-3.2
#	<mgorny> but this pattern is quoted since it goes to find
#	<mgorny> and find uses the pattern
#	<mgorny> i've also switch find to use the 'new'
#		-exec foo {} + syntax
#	<joe9> oh, ok. thanks.
#	<mgorny> which is easier to type and faster than {} \;
#	<mgorny> since {} \; runs the command once for each file
#	<mgorny> like touch a; touch b; touch c
#	<mgorny> and {} + passes all files to one command
#	<mgorny> like touch a b c
	find -name '*.[ly]' -type f -exec touch '{}' +
}

src_configure() {
	my_configure() {
		local pic30path="/usr/share/pic30"
		# Default smartio_rules, the value can be 0, 1 or 2
		# The value has to be supported by the C library
		#  and be the same as in pic30_binutils
		local c30_smartio_rules=2

		# -x   Mark each name for export to subsequent commands
		#	via the environment.
		local -x CFLAGS="${CFLAGS} \
						 -DC30_SMARTIO_RULES=$c30_smartio_rules \
						 -DMCHP_VERSION=v${PV}-gentoo \
						 -DPIC30MAGIC \
						 -DPIC30 \
						 -DPIC30PATH=\"$pic30path\" "
		local myeconfargs=(
			--target="pic30-${MULTIBUILD_VARIANT}"
		)

		if [[ "${MULTIBUILD_VARIANT}" == "elf" ]]
		then
			CFLAGS+=" -DPIC30ELF"
		fi
		# cd acme
		# S="${S}/acme" autotools-utils_src_configure
			# --build=x86_64-pc-linux-gnu \
			# --host=x86_64-pc-linux-gnu \
			# --libdir=/usr/lib64 \
		mkdir -p "${S}/build-${MULTIBUILD_VARIANT}"
		cd "${S}/build-${MULTIBUILD_VARIANT}"
		"${S}/acme/configure" \
			--prefix=/usr \
			--mandir=/usr/share/man \
			--infodir=/usr/share/info \
			--datadir=/usr/share \
			--sysconfdir=/etc \
			--localstatedir=/var/lib \
			--target="pic30-${MULTIBUILD_VARIANT}"
	}

	multibuild_foreach_variant my_configure
}

src_compile() {
	multibuild_foreach_variant autotools-utils_src_compile
}

src_install() {
	multibuild_foreach_variant autotools-utils_src_install
}
