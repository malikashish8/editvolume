# editvolume
[![Build Status](https://travis-ci.com/malikashish8/editvolume.svg?branch=master)](https://travis-ci.com/malikashish8/editvolume)

Edit contents of a docker volume on host in real time using tools/editors installed on host. This is useful for debugging running containers, editing the config files in a volume etc. Changes are automatically detected and files/folder are synced.

## Usage
Run `editvolume` by mounting the **volume** to be edited and the **host folder** on which contents of volume will be available:
```bash
docker run --rm -it \
    -e "HOSTUSER=`id -u`" \
    -v <volume_to_edit>:/volume \
    -v <host_folder>:/folder \
    malikashish8/editvolume
```
example:
```bash
docker run --rm -it \
    -e "HOSTUSER=`id -u`" \
    -v jenkins_config:/volume \
    -v ~/jenkins_config:/folder \
    malikashish8/editvolume
```
> `HOSTUSER` is required to change ownership of copied files to host user


Files are synced as long as __editvolume__ is run. To constantly sync files run it in detached (`-d`) mode.