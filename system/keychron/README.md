# Keychron M6 input configuration

Working X11/dwm setup for the M6 8K and Ultra-Link receivers. This preserves the
configuration the user reported working on 2026-11-08. The diagnostic programs,
services, logs, recordings, and unsuccessful input-filter experiments are not
part of this setup.

- `motion-batching.patch` combines consecutive Keychron motion events already
  queued by libinput. It preserves accelerated and raw movement totals and
  flushes before clicks, scrolling, or events from another device. It adds no
  timer or polling-rate cap; the mouse remains set to 8000 Hz in its firmware.
- `etc/libinput/plugins/90-keychron-horizontal.lua` doubles horizontal wheel
  movement on the original device. Vertical scrolling is unaffected.
- `etc/X11/xorg.conf` is this workstation's active Xorg configuration. Its custom
  module path loads the rebuilt driver before the distribution's driver.

The patch and plugin match Keychron vendor `3434`, product `d049` (M6 wired)
and `d028` (Ultra-Link receiver). Both identical receivers are covered.

## Rebuild the driver

The distribution driver used here lacked libinput plugin support. The build
uses upstream xf86-input-libinput 1.5.0, pinned to commit
[`ac862672e4d04e78f2b647af9d3d14544454e4b9`](https://gitlab.freedesktop.org/xorg/driver/xf86-input-libinput/-/commit/ac862672e4d04e78f2b647af9d3d14544454e4b9),
plus the included motion patch. Upstream retains its own license; the patch
contains the local changes.

Build dependencies on this Arch/Artix setup: `base-devel`, `git`, `libinput`,
`xorg-server-devel`, `xorgproto`, and `xorg-util-macros`. The working setup was
built against Xorg 21.1.25 and libinput 1.32.0. Use matching installed Xorg
headers and rebuild after driver/library ABI changes.

From this directory:

```sh
./build-driver.sh
```

This fetches the pinned source, applies the patch, verifies plugin support,
builds the module, and runs the upstream checks. Output and build logs go in
`build/`, which is ignored by Git. No compiled driver binary is committed.
Optional build settings: `KEYCHRON_BUILD_DIR` and `KEYCHRON_BUILD_JOBS`.

## Install

```sh
sudo install -Dm755 build/libinput_drv.so /usr/local/lib/keychron-xorg/modules/input/libinput_drv.so.next
sudo mv -f /usr/local/lib/keychron-xorg/modules/input/libinput_drv.so.next /usr/local/lib/keychron-xorg/modules/input/libinput_drv.so
sudo install -Dm644 etc/libinput/plugins/90-keychron-horizontal.lua /etc/libinput/plugins/90-keychron-horizontal.lua
```

The atomic rename allows the current Xorg session to keep using its loaded
module until restart. The packaged `/usr/lib/xorg/modules/input/libinput_drv.so`
is not overwritten.

The saved Xorg file includes this machine's graphics configuration, including
`PCI:9:0:0`. On this workstation, back up the existing configuration before
installing the saved file:

```sh
sudo cp -an /etc/X11/xorg.conf /etc/X11/xorg.conf.before-keychron-rice
sudo install -m644 etc/X11/xorg.conf /etc/X11/xorg.conf
```

On another machine, retain its graphics configuration and add these paths to
its existing `Section "Files"`, in this order, instead of copying the full file:

```xorg
ModulePath "/usr/local/lib/keychron-xorg/modules"
ModulePath "/usr/lib/xorg/modules"
```

Save work and restart X11 to activate the driver and plugin. No debugging
program or background recorder is required for the input configuration.

## Rollback

Remove the custom module-path entry from `/etc/X11/xorg.conf` and remove
`/etc/libinput/plugins/90-keychron-horizontal.lua`, then restart X11 after
saving work. Xorg will load the untouched distribution driver again.
