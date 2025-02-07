# Automatic update of sysext images on openSUSE MicroOS

With `importctl` and `systemd-sysext` it is easy to import an sysext image and merge it into the system. But there are two scenarios, where we want to update this image:

1. there is new image with fixes
2. the current image is incompatible with the OS update

systemd provides for this `systemd-sysupdate` and since v257 additional `updatectl` and `systemd-updated`.

The problem: since systemd v257 this tools expect that the images have all the same version number. And that you have a "host" image. This is absolute fine if your OS consists of several partitions and the images needs to fit together (e.g. `/boot` and `/usr`), but what about sysext images?

The sysext images are system extensions.
You can see them in two ways:
1. this are optional components of the OS but have a strict dependency to it, means they need to be updated with the host OS images.
2. this are 3rd party images or enhancements of the OS, which are only lightly grouped together. They are updated independent of the OS and only needs rarly an update if the host OS gets updated.

For case one enforcing the same version number as the host OS is most of the time really simple. But it also means, if the distributor needs to update a sysext image, all images have the be updated with the new version number, and the customer needs to update them all, too. Even if the content hasn't changed at all.

In the second case it's impossible to have the same version number. All 3rd party vendors would need to update the version number at the same time in a coordinated way, if only one of them needs to release an update. And the user would need to update all images only to get e.g. a security fix for a very small extension. An example could be k3s: it's developed completly independent of the host OS and does not need an update if the host OS get's updated.
