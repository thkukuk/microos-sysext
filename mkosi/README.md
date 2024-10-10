# Building sysext images with mkosi for openSUSE MicroOS

This directory contains the directories and scripts for `mkosi` to build sysext images for openSUSE MicroOS. This images are raw disk images with a gpt partition table and erofs as filesystem.
The dm-verity protection is disabled.

`mkosi` >= 25~devel+20241009.7b138bc is required.

## How to use

### Command line

Since `mkosi` requires some tools from `/usr/sbin`, the search path needs to be enhanced if the tool should run as normal user:
* `PATH=$PATH:/usr/sbin mkosi -f`

This will build a base image as specified by `patterns-microos-basesystem` and sysext images on top of that image.

### OBS (Open Build Service)

There is a project which builds sysext images for openSUSE MicroOS:

* Project: https://build.opensuse.org/project/show/home:kukuk:sysext
* Download: https://download.opensuse.org/repositories/home:/kukuk:/sysext/mkosi/

## Open Issues

* ~~How to disable the build of the default `image.raw` image? It's not needed.~~
* ~~How to disable dm-verity? It may be overkill and increases the size too much.~~
* ~~How to remove the RPM database from the sysext images? They don't make sense and will conflict each other, but require a huge amount of disk space.~~
* mkiso: How to build sysext images with squashfs?
* mkiso: How to create "useful" image names? E.g. `strace-<RPM Version>_<OBS Build Version>.<arch>.raw`
* OBS: `mkiso.conf` files should not be published
* OBS: How to create a SHA256SUMS file?
* OBS: How to gpg sign that SHA256SUMS file?

