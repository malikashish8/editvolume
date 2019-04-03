#!/usr/bin/evn sh

usage() {
    echo "usage sample:"
    echo "docker run --rm -e \"EDITUSER=\`id -u\`\" -v <volume_to_edit>:/volume -v <host_folder>:/folder editvolume"
}

[[ -z ${EDITUSER} ]] && echo EDITUSER parameter is required && usage && exit 1

echo "Copying files from volume to local folder"
rsync --delete -r /volume/ /folder/ 1>/dev/null

echo "Userid $EDITUSER"
chown -R "$EDITUSER:$EDITUSER" /folder
echo "Copy complete"

notify_folder() {
    inotifywait -r -m -e modify -e move -e create -e delete /folder 2>/dev/null
}

notify_folder | tee /dev/stderr | while read line; do echo 'update folder->volume' && rsync --delete -r /folder/ /volume/; done &

notify_volume() {
    inotifywait -r -m -e modify -e move -e create -e delete /volume 2>/dev/null
}

notify_volume | while read line; do echo 'update volume->folder' && rsync --delete -r /volume/ /folder/; done