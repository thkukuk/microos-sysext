# Building sysext images for openSUSE MicroOS

This repository contains the needed config files and scripts to build sysext images with `mkosi` to enhance openSUSE MicroOS. This images are raw disk images with a gpt partition table and erofs as filesystem.
The dm-verity protection is disabled.

## Why systemd-sysext images?

openSUSE MicroOS is an immutable system with a read-only root filesystem. Which means, it is not possible without reboot to install additional packages. But most of the time the tools required to debug issues are not installed when you need them.
openSUSE MicroOS has the `toolbox` command for this, which starts a privileged container, in which the necessary tools can be installed without reboot.
But what if the problem is with the container runtime or the network? In this case, the `toolbox` command does not work, too. The idea is to provide lightwight images containing the most important tools, which can easly be added with [systemd-sysext](https://manpages.opensuse.org/systemd-sysext.8) to the system.

## Setup

The setup to use sysext images consists of two parts:

### Server
A web server provides the sysext images in a directory. The format of the image name is `<name>-<build>.<arch>.raw`, where \<name\> is the official name of the image as used in `extension-release` meta data.

A SHA256SUMS file contains the sha256 checksums and the name of each image. This file is used by `systemd-sysupdate` to check for new image versions.

The data can optional be signed with a gpg key.

An example directory listing would look like:
```
SHA256SUMS
debug-4.2.x86-64.raw
gcc-4.2.x86-64.raw
strace-4.2.x86-64.raw
```

### Client

On the client, the image is stored in `/var/lib/sysext-store` and symlinked to `/etc/extensions`. The symlink must be the `<name>` plus the `.raw` suffix without version number.

Example:
```
/var/lib/sysext-store/debug-4.2.x86-64.raw
/etc/extensions/debug.raw -> ../../var/lib/sysext-store/debug-4.2.x86-64.raw
```

The `systemd-sysext.service` will automatically merge the images at bootup if enabled, else this has to be done manual with `systemd-sysext merge`.

Installation and update of the images should happen with `systemd-sysupdate` according to the config files in `/etc/sysupdate.d`. This is work in progress.

## Client Prerequires

### Packages

The following packages needs to be installed:
* systemd (`systemd-sysext`)
* systemd-experimental (`systemd-sysupdate`)
* systemd-container (`systemd-pull`)

### Directories

The following directories needs to be created:
* `/var/lib/sysext-store`
* `/etc/extensions`

### Enable services
* systemd-sysext.service
* systemd-sysupdate.timer

## Directories
* [mkosi.images](mkosi.images) - Config files to build sysext images with `mkosi`
* [sysupdate.d](sysupdate.d) - Example config files for systemd-sysupdate
* [old scripts](old-scripts) - Old script which unpacks RPMs and builds sysext images from it

## Building sysext images with mkosi

For this config `mkosi` >= 25~devel+20241009.7b138bc is required.

### Command line

Since `mkosi` requires some tools from `/usr/sbin`, the search path needs to be enhanced if the tool should run as normal user:
* `PATH=$PATH:/usr/sbin mkosi -f`

This will build a base image as specified by `patterns-microos-basesystem` and sysext images on top of that image.

For SELinux support, this needs to run as `root`.

### OBS (Open Build Service)

There is a project which builds sysext images for openSUSE MicroOS:

* Project: https://build.opensuse.org/project/show/home:kukuk:sysext
* Download: https://download.opensuse.org/repositories/home:/kukuk:/sysext/mkosi/

#### Open Issues (OBS)
* `mkosi.conf` files should not be published
* How to create a SHA256SUMS file?
* How to gpg sign that SHA256SUMS file?

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
