# Automatic update of sysext images on openSUSE MicroOS

## Use cases for sysext images

### Debugging tools and compiler

Admin detects a problem with an application, network or something similar. The prefered tool for debugging this issue is not installed by default. Installing it as RPM or an modified image would mean, a reboot is necessary. In most cases this means, the issue cannot be debugged anymore.

Instead the admin imports a sysext image with the debugging tool, compiler or what else he needs to quickly debug the system without reboot.

### External software stack

There is one team/unit which creates an OS with read-only root filesystem and atomic updates. In this case this would be openSUSE MicroOS with transactional-update and RPM or OCI container image based updates build in OBS.

An different (external) team maintains k3s, and they also want to release sysext images for MicroOS.
Since k3s is a static linked go binary, there are no dependencies to the host OS, it can run on every system. They build the binary and the sysext image in their own build system.

The version of the sysext image is identical with the version of the binary. New sysext images will only be released if they need to release a new binary. The dependency of the image is "ID=_any".


### Upstream

The `systemd-sysext` documentation states:

```
The primary use case for system images are immutable environments where debugging and development tools shall optionally be made available, but not included in the immutable base OS image itself (e.g. strace(1) and gdb(1) shall be an optionally installable addition in order to make debugging/development easier). System extension images should not be misunderstood as a generic software packaging framework, as no dependency scheme is available: system extensions should carry all files they need themselves, except for those already shipped in the underlying host system image. Typically, system extension images are built at the same time as the base OS image — within the same build system.
```

This is theoretically correct, but especially the "system extension images are built at the same time as the base OS image" is only realistic doable in a closed ECO system. But in reality, different (external) teams want to provide their software for this OS, which is not always possible to do as container. Like k3s. Thus they need to use systemd-sysext images.


## Workflow

### Manual

Importing the systemd-sysext images manual is the typical workflow for use case "Debugging tools and compiler".
Use `importctl` to import the image and `systemd-sysext` to merge it into the system. Afterwards use the tools.
E.g.:
```
importctl pull-raw --class=sysext https://download.opensuse.org/repositories/[...]/strace-6.13.raw
systemd-sysext merge
strace [...]
```

### Automatic

If sysext images are used to enhance the systemd with external software (use case "External software stack"), we want that this images get automatically updated.

The low level tool for this is `systemd-sysupdate`.

In the `sysudpate.d` transfer files, all images get marked as `feature`. To use k3s and get that automatically updated:

```
updatectl enable k3s
updatectl update
systemd-sysext merge
```

The upstream solution to update and merge the image automatically on a regular base would be to use `systemd-sysupdate.timer`, but this does not mean that sysext images updates are in sync with OS update after an reboot.

Better would be to let `transactional-update` call `updatectl update`.

## Problems

To keep the sysext images current, systemd provides for `systemd-sysupdate` and since v257 additional `updatectl` and `systemd-updated`.

The problem: since systemd v257 this tools expect that the images have all the same version number. And that you have a "host" image. This is absolute fine if your OS consists of several partitions and the images needs to fit together (e.g. `/boot` and `/usr`), but what about sysext images?

The sysext images are system extensions.
You can see them in two ways:
1. this are optional components of the OS but have a strict dependency to it, means they need to be updated with the host OS images.
2. this are 3rd party images or enhancements of the OS, which are only lightly grouped together. They are updated independent of the OS and only needs rarly an update if the host OS gets updated.

For case one enforcing the same version number as the host OS is most of the time really simple. But it also means, if the distributor needs to update a sysext image, all images have the be updated with the new version number, and the customer needs to update them all, too. Even if the content hasn't changed at all.

In the second case it's impossible to have the same version number. All 3rd party vendors would need to update the version number at the same time in a coordinated way, if only one of them needs to release an update. And the user would need to update all images only to get e.g. a security fix for a very small extension. An example could be k3s: it's developed completly independent of the host OS and does not need an update if the host OS get's updated.
