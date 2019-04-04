#!/usr/bin/evn sh

trap 'cleanup' 1 2 3 6

cleanup() {
    echo "shutting down"
    exit 0
}

[[ ! -z ${DEBUG} ]] && set -x

usage() {
    echo "usage sample:"
    echo "docker run --rm -it -e \"HOSTUSER=\`id -u\`\" -v <volume_to_edit>:/volume -v <host_folder>:/folder editvolume"
}

[[ -z ${HOSTUSER} ]] && echo HOSTUSER parameter is required && usage && exit 1

# Get UID of Volume folder (with busybox) - used for new files
VOLUMEUSER=$(ls -ld  /volume | awk 'NR==1 {print $3}')
re='[0-9]\+'
if ! expr "$VOLUMEUSER" : "$re"; then
    VOLUMEUSER=$(id -u $VOLUMEUSER)
fi 1>/dev/null

echo "copying `du -h -d0 /volume | cut -f1` from volume to host folder"
rsync --delete --owner --group --chown="$HOSTUSER:$HOSTUSER" --recursive /volume/ /folder/ 1>/dev/null

#chown --recursive "$HOSTUSER:$HOSTUSER" /folder
echo "copy complete"

notify_folder() {
    inotifywait --recursive --monitor --event modify,move,create,delete /folder 2>/dev/null
}

notify_folder | while read line
do 
    echo "folder -> volume $line"
    rsync --delete --update --owner --group --chown="$VOLUMEUSER:$VOLUMEUSER" --recursive /folder/ /volume/
    #chown --recursive "$VOLUMEUSER:$VOLUMEGROUP" /volume
done 2>&1 &

notify_volume() {
    inotifywait --recursive --monitor --event modify,move,create,delete /volume 2>/dev/null
}

notify_volume | while read line
do 
    echo "volume -> folder $line"
    rsync --delete --update --owner --group --chown="$HOSTUSER:$HOSTUSER" --recursive /volume/ /folder/
    #chown --recursive "$HOSTUSER:$HOSTUSER" /folder
done 