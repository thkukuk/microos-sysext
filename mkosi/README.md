# Building sysext images with mkosi for openSUSE MicroOS

This directory contains the directories and scripts for `mkosi` to build sysext images for openSUSE MicroOS. This images are raw disk images with a gpt partition table and protected via dm-verity.

## How to use

At first a key for dm-verity needs to be generated:
* `mkosi genkey`

Afterwards we can build the images:
* `PATH=$PATH:/usr/sbin mkosi -f`

This will build a base image as specified by `patterns-microos-basesystem` and sysext images on top of that image.

## Open Issues

* How to disable the build of the default `image.raw` image? It's not needed.
* How to disable dm-verity? It may be overkill and increases the size too much.
* How to remove the RPM database from the sysext images? They don't make sense and will conflict each other, but require a huge amount of disk space.
* How to build sysext images with squashfs?
