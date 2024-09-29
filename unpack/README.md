# Script to create sysext images in squashfs format

This directory creates a script `microos-sysext.sh` which creates sysext images in squashfs format by unpacking the RPMs.

Workflow:
* Download all RPMs for the MicroOS basesystem pattern
* Download all RPMs required for a package in a second directory
  * Remove all RPMs of the basesystem pattern from it
  * Unpack the remaining RPMs
  * Create a squashfs image from it

## Open Issues

* Needs to run as root
* Since the suggests of the base pattern are not used for the second directory, the solver can make different choices (e.g. libz1 vs. libz-ng-compat1).
