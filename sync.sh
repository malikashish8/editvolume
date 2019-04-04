#!/usr/bin/evn sh

trap 'cleanup' 1 2 3 6

cleanup() {
    echo "shutting down"
    exit 0
}

[[ ! -z ${DEBUG} ]] && set -x

usage() {
    echo "usage sample:"
    echo "docker run --rm -it -e \"HOSTUSER=\`id -u\`\" -v <volume_to_edit>:/volume -v <host_folder>:/folder malikashish8/editvolume"
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

echo "copy complete"

notify_folder() {
    inotifywait --recursive --monitor --event modify,move,create,delete /folder 2>/dev/null
}
sync_volume() {
    notify_folder | while read line
    do
        echo "folder -> volume $line"
        # Switch to one directional sync to avoid stepping over ourself
        ps>/tmp/f1
        FOLDER_PID=$(cat /tmp/f1 | grep '/volume' | awk 'NR==1 {print $1}')
        [[ ! -z "$FOLDER_PID" ]] && kill $FOLDER_PID

        rsync --delete --update --owner --group --chown="$VOLUMEUSER:$VOLUMEUSER" --recursive /folder/ /volume/
        # Switch back to bi-directional sync
        sync_folder
    done &
}


notify_volume() {
    inotifywait --recursive --monitor --event modify,move,create,delete /volume 2>/dev/null
}
sync_folder() {
    notify_volume | while read line
    do 
        echo "volume -> folder $line"
        # Switch to one directional sync to avoid stepping over ourself
        ps>/tmp/f2
        VOLUME_PID=$(cat /tmp/f2 | grep '/folder' | awk 'NR==1 {print $1}')
        [[ ! -z "$VOLUME_PID" ]] && kill $VOLUME_PID
        rsync --delete --update --owner --group --chown="$HOSTUSER:$HOSTUSER" --recursive /volume/ /folder/
        # Switch back to bi-directional sync
        sync_volume
    done &
}

sync_folder
sync_volume

# keep the container running
while true; do sleep 500; done

