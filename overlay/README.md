# Script to create sysext images in squashfs format using overlayfs

This directory creates a script `microos-sysext.sh` which creates sysext images in squashfs format. For this, at first all packages of the MicroOS basesystem pattern will be installed into a directory. Afterwards, an overlayfs will be put on this directory and we install the package on top of it, using the base system RPM database for dependency solving. This solves the solver issues of the `unpack` variant.

Workflow:
* Install all RPMs from the MicroOS basesystem pattern in one directory (`zypper --installroot <dir> install ...`)
* Create an overlayfs on this directory
* Install the package, for which a sysext image should be created on top of it
* Create a squashfs image from the overlayfs directory

## How to use

**WIP**

## Open Issues

* Needs to run as root
