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
# MULTIBUILD_VARIANTS=( coff )

S="${WORKDIR}"

src_prepare() {
	# There is a problem with finding the resource file
	# Here we add some alternatives locations.
	# Only those places will be searched before giving up
	# <mgorny> <<-_EOF_ is heredoc
	# <mgorny> everything from next line to _EOF_ is put into that file
	# <mgorny> plus the '-' makes it strip leading whitespace
	cat > gcc-4.0.2/gcc-4.0.2/c30_device_info_path.h <<-_EOF_ || die
		char *pic30_resource_files[] = {
			"/usr/share/pic30/c30_device.info",
			"/usr/share/pic30/bin/c30_device.info",
			0
		};
	_EOF_

	echo "#define MCHP_VERSION v${PV} for Gentoo Linux" \
		>gcc-4.0.2/gcc-4.0.2/mchp_version.h || die

	find . -type f -exec dos2unix --force {} \;

	# epatch --merge -p0 -i $SRC/remove-omf.diff
	# the above .diff file is not working.
	# The omf flag seemed to be introducing issues when
	#  gcc called its subcommands (e.g. cc1) so I removed it.
	# find . -type f -exec sed -i -e 's/-omf=%(omf)//g' {} \;
	sed -i -e 's/-omf=%(omf)//g' "${S}/gcc-4.0.2/gcc-4.0.2/gcc/gcc.c"

	# patch --merge -p0 -i $SRC/program-prefix-fix.diff
	# the above .diff file is removing the OMF definition
	sed -i -e '/host_xm_defines/s/pic30-/${program_prefix}/g' \
		 "${S}/gcc-4.0.2/gcc-4.0.2/gcc/config.gcc"

	epatch "${FILESDIR}/libiberty-testsuite.diff"
	# below included in version 3_31
	epatch "${FILESDIR}/pic30-standard-prefix.diff"
	# epatch "${FILESDIR}/search-path-fix.diff"
	epatch "${FILESDIR}/make-relative-prefix.diff"
	# epatch "${FILESDIR}/delete_location_of_c30_device_info.resource-path.diff"
	epatch "${FILESDIR}/t-pic30.diff"

	# the below files from arch build
	epatch "${FILESDIR}/resource.patch"
	epatch "${FILESDIR}/bugfix.patch"
	epatch "${FILESDIR}/configure.patch"
	epatch "${FILESDIR}/gcc.c.patch"
	# the below works only on 3.31 and not on 3.30b
	# epatch "${FILESDIR}/resource.c.patch"
	epatch "${FILESDIR}/default-include-path.patch"
	epatch "${FILESDIR}/docs.patch"
	# epatch "${FILESDIR}/version.patch"
	epatch "${FILESDIR}/c30_flag_definitions.h.patch"
	epatch "${FILESDIR}/pic30.c.patch"
	# epatch "${FILESDIR}/disable-fixinc.patch"

	# got the below from c30-linux patches
	epatch "${FILESDIR}/pic30.c.host_int.patch"
	epatch "${FILESDIR}/pic30-protos.h.patch"

	sed -i \
	  -e 's,pic30_license_valid = 0;,pic30_license_valid = 1;,g' \
	  -e '/if (pid == -1) pfatal_pexecute (err_msg, exec);/,+5d' \
	  -e 's/PIC30_BUILTIN_WRITEPWMSFR,/PIC30_BUILTIN_WRITEPWMSFR/g' \
			   "${S}/gcc-4.0.2/gcc-4.0.2/gcc/config/pic30/pic30.h"

	# remove the resource version warning
	#   and using a patch instead of the below sed script
	# sed -i \
	#    -e '/pic30_conversion_status conv_flags;/ d' \
	#    -e '/unsigned int function_convertable;/ a pic30_conversion_status conv_flags;' \
	#    -e '/free(exec);/ i pic30_license_valid = 1;' \
	#             gcc-4.0.2/gcc-4.0.2/gcc/config/pic30/pic30.c
	# sed -i -e '/free(exec);/ i pic30_license_valid = 1;' \
	#        gcc-4.0.2/gcc-4.0.2/gcc/config/pic30/pic30.c
	epatch "${FILESDIR}/pic30.c.remove_warnings.patch"

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
		local -x CFLAGS=" -g ${CFLAGS} \
						 -DC30_SMARTIO_RULES=$c30_smartio_rules \
						 -DMCHP_VERSION=v${PV}-gentoo \
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
		"${S}/gcc-4.0.2/gcc-4.0.2/configure" \
			--prefix=/usr \
			--mandir=/usr/share/man \
			--infodir=/usr/share/info \
			--datadir=/usr/share \
			--sysconfdir=/etc \
			--localstatedir=/var/lib \
			--enable-languages=c \
			--enable-target-optspace \
			--without-headers \
			--with-as=/usr/bin/pic30-coff-as \
			--with-ld=/usr/bin/pic30-coff-ld \
			--enable-debug \
			--disable-fixincludes \
			--target="pic30-${MULTIBUILD_VARIANT}"
	}

	multibuild_foreach_variant my_configure
}

src_compile() {
	multibuild_foreach_variant autotools-utils_src_compile
}

src_install() {
	multibuild_foreach_variant autotools-utils_src_install
	my_cleanup() {
	rm -fr \
	"$D/usr/libexec/gcc/pic30-${MULTIBUILD_VARIANT}/4.0.3/install-tools"
	}
	multibuild_foreach_variant my_cleanup
}
