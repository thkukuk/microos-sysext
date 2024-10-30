#!/bin/sh

WORKDIR=build
IMAGES=store

SYSEXTS="strace gdb traceroute"

OS="${OS-_any}"
FORMAT="${FORMAT:-squashfs}"
ARCH="${ARCH-$(arch)}"

# Set this to build time of RPM
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH-0}"
export SOURCE_DATE_EPOCH

# zypper_download
# TODO:
# * solve package together with base pattern to get
#   Suggests from the patterns right, else libz-ng-compat1
#   is used instead of libz1
# * zypper install requires to be root

zypper_download()
{
    PKG="$1"

    mkdir -p "$WORKDIR/$PKG"
    zypper --disable-system-resolvables --non-interactive  --pkg-cache-dir="$WORKDIR/$PKG" install --no-recommends --auto-agree-with-licenses --auto-agree-with-product-licenses --download-only libz1 "$PKG"
    find "$WORKDIR/$PKG" -name "*.rpm" | sed -e "s|$WORKDIR/$PKG/||g" > "$WORKDIR/$PKG.txt"
}

remove_base_RPMs()
{
    BASE="$1"
    PKG="$2"

    for pkg in $(cat "$WORKDIR/$BASE.txt") ; do
	test -f "$WORKDIR/$PKG/$pkg" && rm -f "$WORKDIR/$PKG/$pkg"
    done
}

unpack_RPM()
{
    CPIO_OPTS="--extract --unconditional --preserve-modification-time --make-directories"

    RPM="$1"
    DIR="$2"

    mkdir -p "$DIR"
    rpm2cpio "$RPM" | cpio ${CPIO_OPTS} -D "$DIR"
}

map_ARCH()
{
    # Map to valid values for https://www.freedesktop.org/software/systemd/man/os-release.html#ARCHITECTURE=
    case "$1" in
	"x86_64"|"amd64"|"x86-64")
	    ARCH="x86-64"
	    ;;
	"aarch64"|"arm64")
	    ARCH="arm64"
	    ;;
	"s390x")
	    ARCH="s390x"
	    ;;
	"noarch")
	    ARCH=""
	    ;;
	*)
	    echo "Unsupported ARCH=${ARCH}" >&2
	    exit 1
	    ;;
    esac
}

# Main

if [ "${FORMAT}" != "squashfs" ]; then
  echo "Expected FORMAT=squashfs, got '${FORMAT}'" >&2
  exit 1
fi

rm -rf "$WORKDIR"

zypper_download patterns-microos-basesystem
for sysext in $SYSEXTS ; do
    zypper_download "$sysext"
    remove_base_RPMs patterns-microos-basesystem "$sysext"
    for RPM in $(find "$WORKDIR/$sysext" -name "*.rpm") ; do
	unpack_RPM "$RPM" "$WORKDIR/${sysext}-unpacked"
    done
    mkdir -p "$WORKDIR/${sysext}-unpacked/usr/lib/extension-release.d"
    {
	echo "ID=${OS}"
	if [ "${OS}" != "_any" ]; then
	    echo "SYSEXT_LEVEL=1.0"
	fi
	if [ "${ARCH}" != "" ]; then
	    echo "ARCHITECTURE=${ARCH}"
	fi
    } > "$WORKDIR/${sysext}-unpacked/usr/lib/extension-release.d/extension-release.${sysext}"
    rm -f "${IMAGES}/${sysext}".raw

    RPM=$(find "$WORKDIR/$sysext" -name "${sysext}-[0-9]*.rpm")
    map_ARCH $(rpm -q --qf '%{ARCH}' "${RPM}")
    VERSION=$(rpm -q --qf '%{VERSION}-%{RELEASE}' "${RPM}")
    IMAGENAME="${sysext}-${VERSION}"
    if [ "${ARCH}" != "" ]; then
	IMAGENAME="${IMAGENAME}.${ARCH}"
    fi
    	IMAGENAME="${IMAGENAME}.raw"
    
    mksquashfs  "$WORKDIR/${sysext}-unpacked" "${IMAGES}/${IMAGENAME}" -all-root -noappend -xattrs-exclude '^btrfs.'
done

pushd "${IMAGES}" || exit 1
sha256sum -- *.raw > SHA256SUMS
popd || exit 1
