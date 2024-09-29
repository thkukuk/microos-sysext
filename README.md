# Tools to create a systemd-sysext store

This repository contains several scripts and documentation to create a store for systemd-sysext images to enhance openSUSE MicroOS.

## Prerequires

### Packages

The following packages needs to be installed:
* systemd (`systemd-sysext`)
* systemd-experimental (`systemd-sysupdate`)
* systemd-container (`systemd-pull`)

### Directories

The following directories needs to be created:
* /var/lib/sysext-store
* /etc/extensions

`/var/lib/sysext-store` contains the images, `/etc/extensions` contains a symlink to an image, if that should be enabled. The symlink must be the `name` plus the `.raw` suffix without version number.
Example:
```
/var/lib/sysext-store/strace-6.11-1.1.x86-64.raw
/etc/extensions/strace.raw -> ../..//var/lib/sysext-store/strace-6.11-1.1.x86-64.raw
```

### Enable services
* systemd-sysext.service
* Not yet working: systemd-sysupdate.timer

## Directories
* [sysupdate.d](sysupdate.d) - Example config files for systemd-sysupdate
* [unpack](unpack) - Script which unpacks RPMs and builds sysext images from it
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

