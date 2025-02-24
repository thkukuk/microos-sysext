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

A SHA256SUMS file contains the sha256 checksums and the name of each image. This file is used by `systemd-sysupdate` to check for new image versions or by `importctl` to verify that the downloaded image is correct.

The data can optional be signed with a gpg key.

An example directory listing would look like:
```
SHA256SUMS
SHA256SUMS.gpg
debug-4.2.x86-64.raw
gcc-4.2.x86-64.raw
strace-4.2.x86-64.raw
```

### Client

On the client, the image is stored in `/var/lib/extensions`.

Example:
```
/var/lib/extensions/debug-4.2.x86-64.raw
```

The `systemd-sysext.service` will automatically merge the images at bootup if enabled, else this has to be done manual with `systemd-sysext merge`.

## Client Prerequires

### Packages

The following packages needs to be installed:
* systemd (`systemd-sysext`)
* systemd-experimental (`importctl`, `systemd-sysupdate`)
* systemd-container (`systemd-pull`)

### Directories

The following directories needs to be created:
* `/var/lib/extensions`

### Enable services
* systemd-sysext.service

## Directories
* [mkosi.images](mkosi.images) - Config files to build sysext images with `mkosi`
* [sysupdate.d](sysupdate.d) - Example config files for systemd-sysupdate, requires systemd >= 257
* [old scripts](old-scripts) - Old script which unpacks RPMs and builds sysext images from it

## Building sysext images with mkosi

For this config `mkosi` >= 25 is required.

### Command line

Since `mkosi` requires some tools from `/usr/sbin`, the search path needs to be enhanced if the tool should run as normal user:
* `PATH=$PATH:/usr/sbin mkosi -f`

This will build a base image as specified by `patterns-microos-basesystem` and sysext images on top of that image.

For SELinux support, this needs to run as `root`.

### OBS (Open Build Service)

There is a project which builds sysext images for openSUSE MicroOS:

* Project: https://build.opensuse.org/project/show/home:kukuk:sysext
* Download: https://download.opensuse.org/repositories/home:/kukuk:/sysext/mkosi/

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
