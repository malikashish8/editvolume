#!/usr/bin/evn sh

[[ ! -z ${DEBUG} ]] && set -x

usage() {
    echo "usage sample:"
    echo "docker run --rm -e \"EDITUSER=\`id -u\`\" -v <volume_to_edit>:/volume -v <host_folder>:/folder editvolume"
}

[[ -z ${EDITUSER} ]] && echo EDITUSER parameter is required && usage && exit 1

echo "copying files from volume to local folder"
rsync --delete --recursive /volume/ /folder/ 1>/dev/null

chown --recursive "$EDITUSER:$EDITUSER" /folder
echo "copy complete"

notify_folder() {
    inotifywait --recursive --monitor --event modify,move,create,delete /folder 2>/dev/null
}

notify_folder | tee /dev/stderr | while read line
do 
    echo 'update folder -> volume'
    rsync --delete --update --recursive /folder/ /volume/
done 2>&1 &

notify_volume() {
    inotifywait --recursive --monitor --event modify,move,create,delete /volume 2>/dev/null
}

notify_volume | tee /dev/stderr | while read line
do 
    echo 'update volume -> folder'
    rsync --delete --update --recursive /volume/ /folder/
    chown --recursive "$EDITUSER:$EDITUSER" /folder
done 2>&1