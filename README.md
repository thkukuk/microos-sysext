# Tools to create a systemd-sysext store

This repository contains several scripts and documentation to create a store for systemd-sysext images to enhance openSUSE MicroOS.

## Why systemd-sysext images?

openSUSE MicroOS is an immutable system with a read-only root filesystem. Which means, it is not possible without reboot to install additional packages. But most of the time the tools required to debug issues are not installed when you need them.
openSUSE MicroOS has the `toolbox` command for this, which starts a privileged container, in which the necessary tools can be installed without reboot.
But what if the problem is with the container runtime or the network? In this case, the `toolbox` command does not work, too. The idea is to provide lightwight images containing the most important tools, which can easly added with [systemd-sysext](https://manpages.opensuse.org/systemd-sysext.8) to the system.

## Setup

The setup to use sysext images consists of two parts:

### Server
A web server provides the sysext images in a directory. The format of the image name is `<name>-<version>[.arch].raw`, where \<name\> is the official name of the image as used in `extension-release` meta data.

A SHA256SUMS file contains the sha256 checksums and the name of each image. This file is used by `systemd-sysupdate` to check for new image versions.

The data can optional be signed with a gpg key.

An example directory listing would look like:
```
gdb-14.2-2.1.x86-64.raw
SHA256SUMS
strace-6.11-1.1.x86-64.raw
traceroute-2.1.5-1.3.x86-64.raw
```

### Client

On the client, the image is stored in `/var/lib/sysext-store` and symlinked to `/etc/extensions`. The symlink must be the `<name>` plus the `.raw` suffix without version number.

Example:
```
/var/lib/sysext-store/strace-6.11-1.1.x86-64.raw
/etc/extensions/strace.raw -> ../../var/lib/sysext-store/strace-6.11-1.1.x86-64.raw
```

When the `systemd-sysext.service` is enabled it will automatically merge the images at bootup, else this this to be done manual with `systemd-sysext merge`.

Installation and update of the images should happen with `systemd-sysupdate` according to the config files in `/etc/sysupdate.d`. This is not yet really working.

## Client Prerequires

### Packages

The following packages needs to be installed:
* systemd (`systemd-sysext`)
* systemd-experimental (`systemd-sysupdate`)
* systemd-container (`systemd-pull`)

### Directories

The following directories needs to be created:
* /var/lib/sysext-store
* /etc/extensions

### Enable services
* systemd-sysext.service
* Not yet working: systemd-sysupdate.timer

## Directories
* [sysupdate.d](sysupdate.d) - Example config files for systemd-sysupdate
* [unpack](unpack) - Script which unpacks RPMs and builds sysext images from it
* [overlay](overlay) - Script to create the sysext image from an overlay
* [mkosi](mkosi) - Config files to build sysext images with `mkosi`

## Open Questions
* Call systemd-sysupdate refresh
* Compatibility of sysext image with main OS
  * SL Micro 6.0: we can use VERSION\_ID, stays compatibile
  * MicroOS: every snapshot can be incompatible (missing
    library, new library, new major version of library, ...)
    * Force update of all sysext images with every snapshot? (VERSION\_ID)
    * Use SYSEXT\_LEVEL and make version depending glibc version?
      * Not enough if other libraries change
* How to provide /etc/sysupdate.d/\<package\>.conf file?
* How to sign and provide gpg pubkey?
* How to handle SELinux labels?
* How to build in OBS?
  * The image should contain version and release number of the main package and a build number for the image

TODO:
* Allow to build a "debug" sysext image, which consist of several tools, which all are not called "debug".
