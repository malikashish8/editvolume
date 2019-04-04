# malikashish8/editvolume
[![Build Status](https://travis-ci.com/malikashish8/editvolume.svg?branch=master)](https://travis-ci.com/malikashish8/editvolume)

Edit contents of a docker volume on host in real time using tools/editors installed on the host. This is useful for debugging running containers, editing the config files in a volume, development and testing with docker etc. Changes are automatically detected and files/folder are synced.

## Usage
Run `editvolume` by mounting the **volume** to be edited and the **host folder** on which contents of volume will be available:
```bash
docker run --rm -it \
    -e "HOSTUSER=`id -u`" \
    -v <volume_to_edit>:/volume \
    -v <host_folder>:/folder \
    malikashish8/editvolume
```
### Usage Sample:
```bash
dev@ubu:~$ docker run --rm -it \
    -e "HOSTUSER=`id -u`" \
    -v jenkins_config:/volume \
    -v ~/jenkins_config:/folder \
    malikashish8/editvolume
copying 996.0K from volume to host folder
copy complete
folder -> volume /folder/ CREATE plugins.config
folder -> volume /folder/ MODIFY plugins.config
folder -> volume /folder/ MODIFY plugins.config
folder -> volume /folder/ MODIFY plugins.config
folder -> volume /folder/ CREATE config_notes.md
folder -> volume /folder/ MODIFY config_notes.md
folder -> volume /folder/ MOVED_FROM config_notes.md
folder -> volume /folder/ MOVED_TO user_notes.md
folder -> volume /folder/ MOVED_FROM user_notes.md
volume -> folder /volume/ CREATE jenkins.log
volume -> folder /volume/ MODIFY jenkins.log
^Cshutting down
```
> `HOSTUSER` is required to change ownership of copied files to host user


Files are synced as long as __editvolume__ is run. To constantly sync files run it in detached (`-d`) mode.

## Features
* Realtime bi-directional recursive sync between docker volume and folder on host
    * `rsync` used for copying changes
    * `inotifywait` used to detect changes
* User permissions are set automatically:
    * Ownership of Volume files set to volume folder user
    * Ownership of Host Folder files set to current user on host
* Light weight - based on alpine

## Caveat
* Contents of _host folder_ are edited to begin with so inadvertent updates are not made to the volume.