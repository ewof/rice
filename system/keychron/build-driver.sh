#!/bin/sh
# Rebuild the working Xorg input driver; no system files are installed here.
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=${KEYCHRON_BUILD_DIR:-"$script_dir/build"}
repository=https://gitlab.freedesktop.org/xorg/driver/xf86-input-libinput.git
revision=ac862672e4d04e78f2b647af9d3d14544454e4b9

mkdir -p "$build_dir"
build_dir=$(CDPATH= cd -- "$build_dir" && pwd)
source_dir=$(mktemp -d "$build_dir/source.XXXXXX")
trap 'rm -rf -- "$source_dir"' EXIT
trap 'exit 130' INT
trap 'exit 143' HUP TERM

run_logged() {
    log_file=$build_dir/$1
    shift
    if "$@" >"$log_file" 2>&1; then
        return 0
    else
        tail -n 40 "$log_file" >&2
        return 1
    fi
}

printf 'Fetching xf86-input-libinput %s\n' "$revision"
git -C "$source_dir" init -q
run_logged fetch.log git -C "$source_dir" fetch --depth=1 "$repository" "$revision"
git -C "$source_dir" checkout -q --detach FETCH_HEAD
test "$(git -C "$source_dir" rev-parse HEAD)" = "$revision"
git -C "$source_dir" apply --check "$script_dir/motion-batching.patch"
git -C "$source_dir" apply "$script_dir/motion-batching.patch"

cd "$source_dir"
printf 'Configuring against installed Xorg and libinput headers\n'
run_logged configure.log ./autogen.sh --prefix=/usr \
    --with-xorg-module-dir=/usr/local/lib/keychron-xorg/modules --disable-static
if ! grep -q '^#define HAVE_LIBINPUT_PLUGINS 1$' config.h; then
    printf '%s\n' 'libinput plugin support is required; check the installed libinput headers.' >&2
    exit 1
fi

printf 'Building and running upstream checks\n'
run_logged make.log make -j "${KEYCHRON_BUILD_JOBS:-2}"
run_logged check.log make check
install -m 755 src/.libs/libinput_drv.so "$build_dir/libinput_drv.so"
printf '%s\n' "$revision" > "$build_dir/upstream-revision"
printf 'Built %s/libinput_drv.so\n' "$build_dir"
