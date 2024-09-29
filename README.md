# Tools to create a systemd-sysext store

This repository contains several scripts and documentation to create a store for systemd-sysext images to enhance openSUSE MicroOS.

## Prerequires

### Installed Packages

openSUSE MicroOS:
* systemd (systemd-sysext)
* systemd-experimental (systemd-sysupdate)
* systemd-container (systemd-pull)

### Create Directories
* /var/lib/sysext-store
* /etc/extensions

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
  * SL Micro 6.0: we can use VERSION_ID, stays compatibile
  * MicroOS: every snapshot can be incompatible (missing
    library, new library, new major version of library, ...)
    * Force update of all sysext images with every snapshot? (VERSION_ID)
    * Use SYSEXT_LEVEL and make version depending glibc version?
      * Not enough if other libraries change
* How to provide /etc/sysupdate.d/<package>.conf file?
* How to sign and provide gpg pubkey?
* How to handle SELinux labels?
* How to build in OBS?
  * We need version and release number of package and release number of image
